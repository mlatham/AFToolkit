import Foundation

class Sqlite {
	typealias ErrorPointer = AutoreleasingUnsafeMutablePointer<NSError?>
	typealias Statement = OpaquePointer
	typealias Database = OpaquePointer

	typealias QueryClosure = (Database?, inout Error?) -> Any?
	typealias QueryCompletion = (Any?, Error?) -> Void
	typealias CountCompletion = (Int32, Error?) -> Void
	
	typealias StatementClosure = (Database?, inout Error?) -> Void
	typealias StatementCompletion = (Error?) -> Void
	
	enum DataType: String {
		case integer = "INTEGER"
		case text = "TEXT"
		case real = "REAL"
		case numeric = "NUMERIC"
	}
	
	enum Keyword: String {
		case primaryKey = "PRIMARY KEY"
		case autoincrement = "AUTOINCREMEMT"
		case notNull = "NOT NULL"
		case collateNoCase = "COLLATE NOCASE"
		case defaultFalse = "DEFAULT 0"
		case defaultTrue = "DEFAULT 1"
	}
}
