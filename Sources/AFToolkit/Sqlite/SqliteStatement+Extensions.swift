import Foundation
import SQLite3

extension SqliteStatement {
	func bind(column: Int32, string: String?) {
		if let string = string as NSString? {
			sqlite3_bind_text(self, column, string.utf8String, -1, SqliteClient.SQLITE_TRANSIENT)
		} else {
			sqlite3_bind_null(self, column)
		}
	}
	
	func string(column: Int32) -> String? {
		guard let text = sqlite3_column_text(self, column) else {
			return nil
		}
		
		return String(cString: text)
	}
}
