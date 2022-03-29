import Foundation

extension Sqlite {
	class Column: CustomStringConvertible {
		let name: String
		let type: DataType
		let options: [Keyword]
		
		var description: String {
			return name
		}
		
		init(name: String, type: DataType, options: [Keyword] = []) {
			self.name = name
			self.type = type
			self.options = options
		}
	}
}
