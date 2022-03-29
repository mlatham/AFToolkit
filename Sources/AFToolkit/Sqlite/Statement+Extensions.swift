import Foundation
import SQLite3

extension Sqlite.Statement {
	func isNull(_ column: Int) -> Bool {
		return sqlite3_column_type(self, Int32(column)) == SQLITE_NULL
	}

	func bind(column: Int, string: String?) {
		if let string = string as NSString? {
			sqlite3_bind_text(self, Int32(column), string.utf8String, -1, Sqlite.Client.SQLITE_TRANSIENT)
		} else {
			sqlite3_bind_null(self, Int32(column))
		}
	}

	func string(column: Int) -> String? {
		if isNull(column) {
			return nil
		} else if let text = sqlite3_column_text(self, Int32(column)) {
			return String(cString: text)
		}
		return nil
	}
	
	func bind(column: Int, int: Int?) {
		if let int = int {
			sqlite3_bind_int(self, Int32(column), Int32(int))
		} else {
			sqlite3_bind_null(self, Int32(column))
		}
	}
	
	func int(column: Int) -> Int? {
		if isNull(column) {
			return nil
		} else {
			return Int(sqlite3_column_int(self, Int32(column)))
		}
	}
	
	func bind(column: Int, double: Double?) {
		if let double = double {
			sqlite3_bind_double(self, Int32(column), double)
		} else {
			sqlite3_bind_null(self, Int32(column))
		}
	}
	
	func double(column: Int) -> Double? {
		if isNull(column) {
			return nil
		} else {
			return Double(sqlite3_column_double(self, Int32(column)))
		}
	}
}
