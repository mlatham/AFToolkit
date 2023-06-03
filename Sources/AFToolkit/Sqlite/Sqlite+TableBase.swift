import Foundation
import SQLite3

extension Sqlite {
	open class TableBase<T>: NSObject, SqliteTableProtocol {
	
		// MARK: - Properties
		
		// Caches indices for column name lookup.
		private var _columnReadIndices: [String: Int] = [:]
		
		public let client: Client
		
		public let name: String
		public var columns: [SqliteColumnProtocol]
		
		// Returns a comma-separated list of column names (eg: "column").
		public private(set) var allColumnsString: String = ""
		
		// Returns a comma-separated list of full column names (eg: "table.column").
		public private(set) var allFullColumnsString: String = ""
		
		public override var description: String {
			return name
		}
		
		
		// MARK: - Inits
		
		public init(client: Client, name: String, columns: [SqliteColumnProtocol]) {
			// Cache column indices.
			for (i, column) in columns.enumerated() {
				_columnReadIndices[column.name] = i
			}
		
			self.client = client
			self.name = name
			self.columns = columns
			
			super.init()
			
			for column in columns {
				var column = column
				column.table = self
			}
			
			// Initialize the allColumnsString,
			self.allColumnsString = columns.map { "\($0.name)" }.joined(separator: ", ")
			self.allFullColumnsString = columns.map { "\($0.fullName)" }.joined(separator: ", ")
		}
		
		
		// MARK: - Functions
		
		public func readIndex(of column: SqliteColumnProtocol) -> Int {
			return _columnReadIndices[column.name] ?? -1
		}
		
		public func blob(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Data? {
			return statement.blob(at: readIndex(of: column))
		}
		
		public func string(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> String? {
			return statement.string(at: readIndex(of: column))
		}
		
		public func iso8601StringDate(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Date? {
			return statement.iso8601StringDate(at: readIndex(of: column))
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
		
		public func double(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Double? {
			return statement.double(at: readIndex(of: column))
		}
		
		public func doubleNumber(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> NSNumber? {
			return statement.doubleNumber(at: readIndex(of: column))
		}
		
		public func timeIntervalSince1970Date(_ statement: CursorStatement, at column: SqliteColumnProtocol) -> Date? {
			return statement.timeIntervalSince1970(at: readIndex(of: column))
		}
		
		@discardableResult
		public func beginQuery(
			where whereStatement: String? = nil,
			orderBy: String? = nil,
			limit: Int? = nil,
			offset: Int? = nil,
			cache: Bool,
			completion: @escaping Sqlite.QueryCompletion) -> Sqlite.Operation? {
			let query = _query(
				where: whereStatement,
				orderBy: orderBy,
				limit: limit,
				offset: offset)
			return client.beginQuery(
				from: self,
				query: query,
				cache: cache,
				completion: completion)
		}
		
		public func query(
			where whereStatement: String? = nil,
			orderBy: String? = nil,
			limit: Int? = nil,
			offset: Int? = nil,
			cache: Bool) -> [T] {
			let query = _query(
				where: whereStatement,
				orderBy: orderBy,
				limit: limit,
				offset: offset)
			return client.query(from: self, query, cache: cache)
		}
		
		public func count(where whereStatement: String?, cache: Bool) -> Int {
			var query = "SELECT COUNT(*) FROM \(name)"
			if let whereStatement = whereStatement?.nonEmpty {
				query.append(" WHERE \(whereStatement)")
			}
			
			return client.count(query: query, cache: cache)
		}
		
		open func readRow(_ cursor: CursorStatement) -> T? {
			// Abstract.
			fatalError(NotImplementedError)
		}
		
		private func _query(
			where whereStatement: String? = nil,
			orderBy: String? = nil,
			limit: Int? = nil,
			offset: Int? = nil) -> String {
			var query = "SELECT \(allColumnsString) FROM \(name)"
			if let whereStatement = whereStatement?.nonEmpty {
				query += " WHERE \(whereStatement)"
			}

			if let orderBy = orderBy?.nonEmpty {
				query += " ORDER BY \(orderBy)"
			}

			var hasLimit = false
			if let limit = limit {
				query += " LIMIT \(limit)"
				hasLimit = true
			}
			
			if let offset = offset {
				if !hasLimit {
					query += " LIMIT 1"
				}

				query += " OFFSET \(offset)"
			}

			query += ";"
			return query
		}
	}
}
