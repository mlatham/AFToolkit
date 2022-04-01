import Foundation
import SQLite3

extension Sqlite {
	open class TableBase<T>: NSObject, SqliteTableProtocol {
	
		// MARK: - Properties
		
		public let client: Client
		public let name: String
		
		
		// MARK: - Inits
		
		public init(client: Client, name: String) {
			self.client = client
			self.name = name
						
			super.init()
		}
		
		
		// MARK: - Functions
		
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
