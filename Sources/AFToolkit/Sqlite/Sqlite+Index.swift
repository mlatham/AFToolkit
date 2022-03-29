import Foundation

public extension Sqlite {
	struct Index: CustomStringConvertible {
		public let columns: [Column]
		public let name: String
		// Unique keyword?
		
		public var description: String {
			return name
		}
		
		public func createSql(tableName: String) -> String {
			let indexedColumns = columns.map { $0.name }.joined(separator: ", ")
			return "CREATE INDEX IF NOT EXISTS \(name) ON \(tableName)(\(indexedColumns));"
		}
		
		public init(name: String, columns: [Column]) {
			self.name = name
			self.columns = columns
		}
	}
}
