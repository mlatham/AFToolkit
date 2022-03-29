import Foundation
import SQLite3

public extension Sqlite.Statement {
	func isNull(at columnIndex: Int) -> Bool {
		return sqlite3_column_type(self, Int32(columnIndex)) == SQLITE_NULL
	}

	func bind(at columnIndex: Int, string: String?) {
		if let string = string as NSString? {
			sqlite3_bind_text(self, Int32(columnIndex), string.utf8String, -1, Sqlite.Client.SQLITE_TRANSIENT)
		} else {
			sqlite3_bind_null(self, Int32(columnIndex))
		}
	}

	func string(at columnIndex: Int) -> String? {
		if isNull(at: columnIndex) {
			return nil
		} else if let text = sqlite3_column_text(self, Int32(columnIndex)) {
			return String(cString: text)
		}
		return nil
	}
	
	func bind(at columnIndex: Int, int: Int?) {
		if let int = int {
			sqlite3_bind_int(self, Int32(columnIndex), Int32(int))
		} else {
			sqlite3_bind_null(self, Int32(columnIndex))
		}
	}
	
	func int(at columnIndex: Int) -> Int? {
		if isNull(at: columnIndex) {
			return nil
		} else {
			return Int(sqlite3_column_int(self, Int32(columnIndex)))
		}
	}
	
	func bind(at columnIndex: Int, double: Double?) {
		if let double = double {
			sqlite3_bind_double(self, Int32(columnIndex), double)
		} else {
			sqlite3_bind_null(self, Int32(columnIndex))
		}
	}
	
	func double(at columnIndex: Int) -> Double? {
		if isNull(at: columnIndex) {
			return nil
		} else {
			return Double(sqlite3_column_double(self, Int32(columnIndex)))
		}
	}
}
