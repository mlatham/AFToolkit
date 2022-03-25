extension sqlite3_stmt {
	func bind(column: Int, string: String?) {
		if (string == nil) {
			sqlite3_bind_null(self, column)
		} else {
			sqlite3_bind_text(self, column, string?.utf8, -1, SQLITE_TRANSIENT)
		}
	}
	
	func string(column: Int): String? {
		guard let text = UnsafePointer<CChar>(sqlite3_column_text(self, column)) else {
			return nil
		}
		
		return String.fromCString(text) as String?
	}
}
