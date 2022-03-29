import Foundation

extension Sqlite {
	public class Column: CustomStringConvertible {
		public let name: String
		public let type: TypeAffinity
		public let options: [Keyword]
		
		public var description: String {
			return name
		}
		
		public init(name: String, type: TypeAffinity, options: [Keyword] = []) {
			self.name = name
			self.type = type
			self.options = options
		}
		
		public convenience init<ColumnType>(name: String, type: ColumnType.Type, options: [Keyword] = []) {
			let typeAffinity: TypeAffinity
			
			switch type {
			case is String.Type:
				typeAffinity = .text
				
			case is Int.Type, is Bool.Type:
				typeAffinity = .integer
				
			case is Double.Type:
				typeAffinity = .real
				
			// Shouldn't happen.
			default: fatalError("Invalid column type")
			}
			
			self.init(name: name, type: typeAffinity, options: options)
		}
	}
}
