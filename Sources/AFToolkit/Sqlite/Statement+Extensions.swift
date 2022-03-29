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
	
	// Uses GMT and en_us_POSIX locale. TODO: Provide locale?
	func bindIso8601String(at columnIndex: Int, from date: Date?) {
		let string = date?.iso8601GMT
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
	
	func iso8601StringDate(at columnIndex: Int) -> Date? {
		if isNull(at: columnIndex) {
			return nil
		} else if let text = sqlite3_column_text(self, Int32(columnIndex)) {
			let stringDate = String(cString: text)
			return Date.from(iso8601String: stringDate)
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
	
	func bindInt(at columnIndex: Int, number: NSNumber?) {
		if let number = number {
			sqlite3_bind_int(self, Int32(columnIndex), number.int32Value)
		} else {
			sqlite3_bind_null(self, Int32(columnIndex))
		}
	}
	
	func bindInt(at columnIndex: Int, bool: Bool?) {
		if let bool = bool {
			sqlite3_bind_int(self, Int32(columnIndex), bool ? 1 : 0)
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
	
	func intNumber(at columnIndex: Int) -> NSNumber? {
		if isNull(at: columnIndex) {
			return nil
		} else {
			return NSNumber(value: sqlite3_column_int(self, Int32(columnIndex)))
		}
	}
	
	func intBool(at columnIndex: Int) -> Bool? {
		if isNull(at: columnIndex) {
			return nil
		} else {
			return sqlite3_column_int(self, Int32(columnIndex)) != 0
		}
	}
	
	func bind(at columnIndex: Int, double: Double?) {
		if let double = double {
			sqlite3_bind_double(self, Int32(columnIndex), double)
		} else {
			sqlite3_bind_null(self, Int32(columnIndex))
		}
	}
	
	func bindDouble(at columnIndex: Int, number: NSNumber?) {
		if let number = number {
			sqlite3_bind_double(self, Int32(columnIndex), number.doubleValue)
		} else {
			sqlite3_bind_null(self, Int32(columnIndex))
		}
	}

	// Uses GMT and en_us_POSIX locale. TODO: Provide locale?
	func bindTimeIntervalSinceReferenceDouble(at columnIndex: Int, from date: Date?) {
		if let timeInterval = date?.timeIntervalSinceReferenceDate {
			sqlite3_bind_double(self, Int32(columnIndex), timeInterval)
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
	
	func doubleNumber(at columnIndex: Int) -> NSNumber? {
		if isNull(at: columnIndex) {
			return nil
		} else {
			return NSNumber(value: sqlite3_column_double(self, Int32(columnIndex)))
		}
	}
	
	func timeIntervalSinceReferenceDate(at columnIndex: Int) -> Date? {
		if isNull(at: columnIndex) {
			return nil
		} else {
			let timeInterval = TimeInterval(sqlite3_column_double(self, Int32(columnIndex)))
			return Date(timeIntervalSinceReferenceDate: timeInterval)
		}
	}
}
