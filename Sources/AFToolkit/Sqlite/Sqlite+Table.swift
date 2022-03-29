import Foundation
import SQLite3

public extension Sqlite {
	class Table<T>: NSObject {
	
		// MARK: - Properties
		
		public let client: Client
		
		public let name: String
		public let primaryKeys: [Column]
		public let columns: [Column]
		public let indices: [Index]
		
		// Table create statement.
		public let tableCreateStatement: String
		
		// Replace statement which sets all columns.
		public let replaceStatement: String
		
		// All columns on this table, in the order that they're expected for readRow.
		public let allColumnsString: String
		
		// Caches indices for column name lookup.
		private var _columnReadIndices: [String: Int] = [:]
		private var _columnReplaceIndices: [String: Int] = [:]
		
		
		// MARK: - Inits
		
		public init(client: Client, name: String, primaryKeys: [Column], columns: [Column], indices: [Index]) {
			self.client = client
			self.name = name
			self.primaryKeys = primaryKeys
			self.columns = columns
			self.indices = indices
			
			// Cache column indices.
			for (i, column) in columns.enumerated() {
				_columnReadIndices[column.name] = i
				_columnReplaceIndices[column.name] = i + 1
			}
			
			allColumnsString = columns.map { $0.name }.joined(separator: ", ")
			let replaceValuesString = columns.map { _ in "?" }.joined(separator: ", ")
			
			// Generate the create table statement.
			let createColumnsString = columns
				.map { "\($0.name) \($0.type) \($0.options.map { option in option.rawValue }.joined(separator: " "))" }
				.joined(separator: ", ")
			var tableCreateStatement = "CREATE TABLE \(name) (\(createColumnsString));"
			
			// Add a statement to create each index.
			for index in indices {
				tableCreateStatement.append(index.createSql(tableName: name))
			}
			
			self.tableCreateStatement = tableCreateStatement
			
			// Format the replace statement.
			replaceStatement = "INSERT OR REPLACE INTO \(name) (\(allColumnsString)) VALUES \(replaceValuesString)"
		}
		
		
		// MARK: - Functions
		
		public func replaceIndex(of column: Column) -> Int {
			return _columnReplaceIndices[column.name] ?? -1
		}
		
		public func readIndex(of column: Column) -> Int {
			return _columnReadIndices[column.name] ?? -1
		}
		
		public func bind(to statement: Statement, column: Column, string: String?, allowNull: Bool = false) {
			let index = replaceIndex(of: column)
	
			// Set the value if present.
			if (string != nil || allowNull) {
				statement.bind(column: index, string: string)
				
				if selfLogEnabled {
					selfLog(.debug, "Bind column: \(column), value: \(string ?? ""), index: \(index)")
				}
			// Otherwise, don't set the value.
			} else if selfLogEnabled {
				selfLog(.debug, "Skipping null value: \(column), index: \(index)")
			}
		}
		
		public func bind(to statement: Statement, column: Column, int: Int?, allowNull: Bool = false) {
			let index = replaceIndex(of: column)
			
			if (int != nil || allowNull) {
				statement.bind(column: index, int: int)
				
				if selfLogEnabled {
					selfLog(.debug, "Bind column: \(column), value: \(int ?? 0), index: \(index)")
				}
			// Otherwise, don't set the value.
			} else if selfLogEnabled {
				selfLog(.debug, "Skipping null value: \(column), index: \(index)")
			}
		}
		
		// TODO: Is this necessary?
		public func count(where whereStatement: String?, cache: Bool) throws -> Int {
			var query = "SELECT COUNT(*) FROM \(name)"
			if let whereStatement = whereStatement {
				query.append(" WHERE \(whereStatement)")
			}
			
			return client.count(query: query, cache: cache)
		}
		
		public func delete(where whereStatement: String?, cache: Bool) throws {
			try client.execute { database, error in
				var query = "DELETE FROM \(name)"
				if let whereStatement = whereStatement {
					query.append(" WHERE \(whereStatement)")
				}
				
				// TODO: Maybe a generic delete statement?
				// Get or create the cached, prepared statement.
				guard let statement = client.preparedStatement(query: query, cache: cache) else {
					selfLog(.error, "Failed to get prepared delete statement.")
					// TODO: Throw
					return
				}
				
				// TODO: Should this be a single step?
				if sqlite3_step(statement) != SQLITE_DONE {
					// TODO: Throw?
					selfLog(.error, "Error while deleting. \(String(cString: sqlite3_errmsg(database)))")
				}
				
				if cache {
					// Reset the statement.
					sqlite3_reset(statement)
				} else {
					// Finalize the prepared statement if it's not being cached.
					sqlite3_finalize(statement)
				}
			}
		}
		
		public func replace(row: T, preparedReplaceStatement: Statement) {
			// Abstract.
			fatalError(NotImplementedError)
		}
		
		public func readRow(_ statement: Statement) -> T? {
			// Abstract.
			fatalError(NotImplementedError)
		}
		
		public func write(rows: [T], completion: @escaping StatementCompletion) {
			client.beginExecute(statement: { [weak self] database, error in
				self?._write(rows: rows)
			},
			completion: completion)
		}
		
		public func write(rows: [T]) throws {
			try client.execute { [weak self] database, error in
				self?._write(rows: rows)
			}
		}
		
		public func write(row: T, completion: @escaping StatementCompletion) {
			client.beginExecute(statement: { [weak self] database, error in
				self?._write(rows: [row])
			},
			completion: completion)
		}
		
		public func write(row: T) throws {
			try client.execute { [weak self] database, error in
				self?._write(rows: [row])
			}
		}
		
		private func _write(rows: [T]) {
			// Get or create the cached, prepared statement.
			guard let statement = client.preparedStatement(query: replaceStatement, cache: true) else {
				selfLog(.error, "Failed to get prepared replace statement.")
				// TODO: Throw
				return
			}
			
			for row in rows {
				replace(row: row, preparedReplaceStatement: statement)
				
				// Reset the statement.
				sqlite3_reset(statement)
				
				// Clear any statement bindings.
				sqlite3_clear_bindings(statement)
			}
		}
	}
}
