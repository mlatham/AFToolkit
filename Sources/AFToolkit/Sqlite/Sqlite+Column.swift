import Foundation

public extension Sqlite {
	class Column: CustomStringConvertible {
		public let name: String
		public let type: DataType
		public let options: [Keyword]
		
		public var description: String {
			return name
		}
		
		public init(name: String, type: DataType, options: [Keyword] = []) {
			self.name = name
			self.type = type
			self.options = options
		}
	}
}
