import Foundation

extension Sqlite {
	// Struct so that columns passed into views / tables are passed by value, not reference.
	// This prevents one parent table overriding another.
	public class Column<ColumnType>: CustomStringConvertible, SqliteColumnProtocol {
		public let name: String
		public let affinity: TypeAffinity
		public let options: [Keyword]
		public let type: ColumnType.Type
		
		// Table that owns this column.
		public var table: SqliteTableProtocol?
		
		public var description: String {
			return name
		}
		
		public init(column: Column<ColumnType>) {
			self.init(name: column.name, affinity: column.affinity, type: column.type, options: column.type)
		}
		
		public init(name: String, affinity: TypeAffinity, type: ColumnType.Type, options: [Keyword] = []) {
			self.name = name
			self.type = type
			self.affinity = affinity
			self.options = options
		}
		
		public init(name: String, type: ColumnType.Type, options: [Keyword] = []) {
			let affinity: TypeAffinity
			
			switch type {
			case is String.Type:
				affinity = .text
				
			case is Int.Type, is Bool.Type:
				affinity = .integer
				
			case is Double.Type:
				affinity = .real
				
			// Shouldn't happen.
			default: fatalError("Invalid column type")
			}
			
			self.init(name: name, affinity: affinity, type: type, options: options)
		}
	}
}
