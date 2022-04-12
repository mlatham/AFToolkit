import Foundation

extension Sqlite {
	open class View<T>: TableBase<T> {
		
		// MARK: - Properties
		
		// Create view statement.
		public let createViewStatement: String
		
		
		// MARK: - Inits
		
		public init(client: Client, name: String, columns: [SqliteColumnProtocol], select: String) {
			self.createViewStatement = "CREATE VIEW IF NOT EXISTS \(name) AS \(select);"
			
			super.init(client: client, name: name, columns: columns)
			
			// NOTE: Leave columns qualified with their parent table.
		}
	}
}
