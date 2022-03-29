import Foundation

extension Sqlite {
	struct Index: CustomStringConvertible {
		let columns: [Column]
		let name: String
		// Unique keyword?
		
		var description: String {
			return name
		}
		
		func createSql(tableName: String) -> String {
			let indexedColumns = columns.map { $0.name }.joined(separator: ", ")
			return "CREATE INDEX IF NOT EXISTS \(name) ON \(tableName)(\(indexedColumns));"
		}
		
		init(name: String, columns: [Column]) {
			self.name = name
			self.columns = columns
		}
	}
}
