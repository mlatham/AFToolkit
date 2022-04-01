
import Foundation

public protocol SqliteTableProtocol {
	var name: String { get }
}

public protocol SqliteColumnProtocol {
	var name: String { get }
	var affinity: Sqlite.TypeAffinity { get }
	var options: [Sqlite.Keyword] { get }
	var table: SqliteTableProtocol? { get set }
}

public extension SqliteColumnProtocol {
	var fullName: String {
		if let table = table {
			return "\(table.name).\(name)"
		} else {
			return name
		}
	}
}
