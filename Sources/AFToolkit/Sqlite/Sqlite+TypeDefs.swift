import Foundation

public class Sqlite {
	public typealias ErrorPointer = AutoreleasingUnsafeMutablePointer<NSError?>
	public typealias Statement = OpaquePointer
	public typealias Database = OpaquePointer

	public typealias QueryClosure = (Database?, inout Error?) -> Any?
	public typealias QueryCompletion = (Any?, Error?) -> Void
	public typealias CountCompletion = (Int32, Error?) -> Void

	public typealias StatementClosure = (Database?, inout Error?) -> Void
	public typealias StatementCompletion = (Error?) -> Void
	
	public enum DataType: String {
		case integer = "INTEGER"
		case text = "TEXT"
		case real = "REAL"
		case numeric = "NUMERIC"
	}
	
	public enum Keyword: String {
		case primaryKey = "PRIMARY KEY"
		case autoincrement = "AUTOINCREMEMT"
		case notNull = "NOT NULL"
		case collateNoCase = "COLLATE NOCASE"
		case defaultFalse = "DEFAULT 0"
		case defaultTrue = "DEFAULT 1"
	}
}
