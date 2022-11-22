import Foundation
import SQLite3

extension Sqlite {
	open class Table<T>: TableBase<T> {
	
		// MARK: - Constants
	
		public enum Errors: Error {
			case prepareStatementFailed(String)
			case executionFailed(String)
		}
		
	
		// MARK: - Properties
		
		// Caches indices for column name lookup.
		private var _columnReplaceIndices: [String: Int] = [:]
		
		// Replace statement which sets all columns.
		private var _replaceIntoStatement: String = ""
		
		public let primaryKey: [SqliteColumnProtocol]
		public let indices: [Index]
		
		// Create table statement.
		public let createTableStatement: String
		
		
		// MARK: - Inits
		
		public init(client: Client, name: String, primaryKey: [SqliteColumnProtocol], columns: [SqliteColumnProtocol], indices: [Index]) {
			// Cache column indices.
			for (i, column) in columns.enumerated() {
				_columnReplaceIndices[column.name] = i + 1
			}

			let replaceValuesString = columns.map { _ in "?" }.joined(separator: ", ")
			
			// Generate the create table statement.
			var createColumnsString = columns
				.map { "\($0.name) \($0.affinity) \($0.options.map { option in option.rawValue }.joined(separator: " "))" }
				.joined(separator: ", ")
			if (!primaryKey.isEmpty) {
				createColumnsString.append(", PRIMARY KEY (\(primaryKey.map { $0.name }.joined(separator: ", ")))")
			}
			var createTableStatement = "CREATE TABLE IF NOT EXISTS \(name) (\(createColumnsString));"
			
			// Add a statement to create each index.
			for index in indices {
				createTableStatement.append(index.createSql(tableName: name))
			}
			
			self.createTableStatement = createTableStatement
			self.primaryKey = primaryKey
			self.indices = indices
			
			super.init(client: client, name: name, columns: columns)
			
			// Initialize after allColumnString is set in TableBase.
			_replaceIntoStatement = "INSERT OR REPLACE INTO \(name) (\(allColumnsString)) VALUES (\(replaceValuesString))"
		}
		
		
		// MARK: - Functions
		
		public func replaceIndex(of column: SqliteColumnProtocol) -> Int {
			return _columnReplaceIndices[column.name] ?? -1
		}
		
		public func bind(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, blob: Data?) {
			statement.bind(at: replaceIndex(of: column), blob: blob)
		}
		
		public func bind(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, string: String?) {
			statement.bind(at: replaceIndex(of: column), string: string)
		}
		
		public func bindIso8601String(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, from date: Date?) {
			statement.bindIso8601String(at: replaceIndex(of: column), from: date)
		}
		
		public func bind(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, int: Int?) {
			statement.bind(at: replaceIndex(of: column), int: int)
		}
		
		public func bindInt(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, number: NSNumber?) {
			statement.bindInt(at: replaceIndex(of: column), number: number)
		}
		
		public func bindInt(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, bool: Bool?) {
			statement.bindInt(at: replaceIndex(of: column), bool: bool)
		}
		
		public func bind(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, double: Double?) {
			statement.bind(at: replaceIndex(of: column), double: double)
		}
		
		public func bindDouble(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, number: NSNumber?) {
			statement.bindDouble(at: replaceIndex(of: column), number: number)
		}
		
		public func bindTimeIntervalSince1970Double(
			_ statement: ReplaceStatement,
			at column: SqliteColumnProtocol,
			from date: Date?) {
			statement.bindTimeIntervalSince1970(at: replaceIndex(of: column), from: date)
		}
		
		public func delete(where whereStatement: String?, cache: Bool) throws {
			try client.execute { database, error in
				var query = "DELETE FROM \(name)"
				if let whereStatement = whereStatement?.nonEmpty {
					query.append(" WHERE \(whereStatement)")
				}
				
				// TODO: Maybe a generic delete statement?
				// Get or create the cached, prepared statement.
				guard let statement = client.preparedStatement(query: query, cache: cache) else {
					throw Errors.prepareStatementFailed(query)
				}
				
				if sqlite3_step(statement) != SQLITE_DONE {
					throw Errors.executionFailed("Error deleting. \(String(cString: sqlite3_errmsg(database)))")
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
		
		open func replace(row: T, preparedReplaceStatement: ReplaceStatement) {
			// Abstract.
			fatalError(NotImplementedError)
		}
		
		public func write(rows: [T], completion: @escaping StatementCompletion) {
			client.beginExecute(statement: { [weak self] database, error in
				try self?.client.beginTransaction()
				do {
					try self?._write(rows: rows)
					try self?.client.commitTransaction()
				} catch let e {
					try self?.client.rollbackTransaction()
					throw e
				}
			},
			completion: completion)
		}
		
		public func write(rows: [T]) throws {
			try client.execute { [weak self] database, error in
				try self?.client.beginTransaction()
				do {
					try self?._write(rows: rows)
					try self?.client.commitTransaction()
				} catch let e {
					try self?.client.rollbackTransaction()
					throw e
				}
			}
		}
		
		public func write(row: T, completion: @escaping StatementCompletion) {
			client.beginExecute(statement: { [weak self] database, error in
				try self?._write(rows: [row])
			},
			completion: completion)
		}
		
		public func write(row: T) throws {
			try client.execute { [weak self] database, error in
				try self?._write(rows: [row])
			}
		}
		
		private func _write(rows: [T]) throws {
			// Get or create the cached, prepared statement.
			guard let statement = client.preparedStatement(query: _replaceIntoStatement, cache: true) else {
				throw Errors.prepareStatementFailed(_replaceIntoStatement)
			}
			
			for row in rows {
				replace(row: row, preparedReplaceStatement: statement)
				
				if sqlite3_step(statement) != SQLITE_DONE {
					throw Errors.executionFailed("Error replacing row. \(String(cString: sqlite3_errmsg(client.database)))")
				}
				
				// Reset the statement.
				sqlite3_reset(statement)
				
				// Clear any statement bindings.
				sqlite3_clear_bindings(statement)
			}
		}
	}
}
