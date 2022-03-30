
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
