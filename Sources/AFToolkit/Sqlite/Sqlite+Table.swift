import Foundation
import SQLite3

extension Sqlite {
	open class Table<T>: NSObject, SqliteTableProtocol {
	
		// MARK: - Properties
		
		public let client: Client
		
		public let name: String
		public let primaryKeys: [SqliteColumnProtocol]
		public let columns: [SqliteColumnProtocol]
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
		
		public init(client: Client, name: String, primaryKeys: [SqliteColumnProtocol], columns: [SqliteColumnProtocol], indices: [Index]) {
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
				.map { "\($0.name) \($0.affinity) \($0.options.map { option in option.rawValue }.joined(separator: " "))" }
				.joined(separator: ", ")
			var tableCreateStatement = "CREATE TABLE \(name) (\(createColumnsString));"
			
			// Add a statement to create each index.
			for index in indices {
				tableCreateStatement.append(index.createSql(tableName: name))
			}
			
			self.tableCreateStatement = tableCreateStatement
			
			// Format the replace statement.
			replaceStatement = "INSERT OR REPLACE INTO \(name) (\(allColumnsString)) VALUES \(replaceValuesString)"
			
			super.init()
			
			// Associate each column with this as its owning table.
			for column in columns {
				var column = column
				column.table = self
			}
		}
		
		
		// MARK: - Functions
		
		public func replaceIndex(of column: SqliteColumnProtocol) -> Int {
			return _columnReplaceIndices[column.name] ?? -1
		}
		
		public func readIndex(of column: SqliteColumnProtocol) -> Int {
			return _columnReadIndices[column.name] ?? -1
		}
		
		
		// TODO: Type this as ReplaceStatement
		public func bind(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, string: String?) {
			statement.bind(at: replaceIndex(of: column), string: string)
		}
		
		public func bindIso8601String(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, from date: Date?) {
			statement.bindIso8601String(at: replaceIndex(of: column), from: date)
		}
		
		public func string(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> String? {
			return statement.string(at: readIndex(of: column))
		}
		
		public func iso8601StringDate(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Date? {
			return statement.iso8601StringDate(at: readIndex(of: column))
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
		
		public func int(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Int? {
			return statement.int(at: readIndex(of: column))
		}
		
		public func intNumber(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> NSNumber? {
			return statement.intNumber(at: readIndex(of: column))
		}
		
		public func intBool(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Bool? {
			return statement.intBool(at: readIndex(of: column))
		}
		
		public func bind(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, double: Double?) {
			statement.bind(at: replaceIndex(of: column), double: double)
		}
		
		public func bindDouble(_ statement: ReplaceStatement, at column: SqliteColumnProtocol, number: NSNumber?) {
			statement.bindDouble(at: replaceIndex(of: column), number: number)
		}
		
		public func bindTimeIntervalSinceReferenceDouble(
			_ statement: ReplaceStatement,
			at column: SqliteColumnProtocol,
			from date: Date?) {
			statement.bindTimeIntervalSinceReferenceDouble(at: replaceIndex(of: column), from: date)
		}
		
		public func double(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Double? {
			return statement.double(at: readIndex(of: column))
		}
		
		public func doubleNumber(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> NSNumber? {
			return statement.doubleNumber(at: readIndex(of: column))
		}
		
		public func timeIntervalSinceReferenceDate(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Date? {
			return statement.timeIntervalSinceReferenceDate(at: readIndex(of: column))
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
				
				if sqlite3_step(statement) != SQLITE_DONE {
					// TODO: Throw
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
		
		open func replace(row: T, preparedReplaceStatement: ReplaceStatement) {
			// Abstract.
			fatalError(NotImplementedError)
		}
		
		open func readRow(_ cursor: CursorStatement) -> T? {
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
				
				if sqlite3_step(statement) != SQLITE_DONE {
					let errorMessage = String(cString: sqlite3_errmsg(client.database))
					log(.error, "Error replacing row: \(errorMessage)")
				}
				
				// Reset the statement.
				sqlite3_reset(statement)
				
				// Clear any statement bindings.
				sqlite3_clear_bindings(statement)
			}
		}
	}
}
