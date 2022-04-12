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
		
		
		// MARK: - Inits
		
		// TODO: Once query building, move column to a struct.
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
		}
		
		
		// MARK: - Functions
		
		public func readIndex(of column: SqliteColumnProtocol) -> Int {
			return _columnReadIndices[column.name] ?? -1
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
		
		// TODO: Drop this.
		public func count(where whereStatement: String?, cache: Bool) throws -> Int {
			var query = "SELECT COUNT(*) FROM \(name)"
			if let whereStatement = whereStatement {
				query.append(" WHERE \(whereStatement)")
			}
			
			return client.count(query: query, cache: cache)
		}
		
		open func readRow(_ cursor: CursorStatement) -> T? {
			// Abstract.
			fatalError(NotImplementedError)
		}
	}
}
