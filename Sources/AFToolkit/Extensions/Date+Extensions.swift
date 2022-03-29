import Foundation

fileprivate var dateFormatter = DateFormatter()
fileprivate var iso8601DateFormatter = DateFormatter.iso8601
fileprivate var calendar = Calendar.current

extension Date {
	
	// MARK: - Helper types
	
	enum DateFormatComponents: String {
		/// 2018
		case yearFull = "yyyy"
		/// 18
		case yearShort = "yy"
		
		/// 6
		case monthDigit = "M"
		/// 06
		case monthDigitPadded = "MM"
		/// Jan
		case monthShort = "MMM"
		/// January
		case monthFull = "MMMM"
		/// J
		case monthLetter = "MMMMM"
		
		/// 14
		case dayOfMonth = "d"
		
		/// Tues
		case weekdayMedium = "E"
		/// Tue
		case weekdayShort = "EEE"
		/// Tuesday
		case weekdayFull = "EEEE"
		/// T
		case weekdayLetter = "EEEEE"
		
		/// Localized *13* or *1 PM*, depending on the locale
		case hour = "j"
		/// 20
		case minute = "m"
		/// 08
		case second = "ss"
		
		/// CST
		case timeZone = "zzz"
		/// *Central Standard Time* OR *CST-06:00* if name is unknown
		case timeZoneFull = "zzzz"
	}
	
	enum TimePeriod {
		case beginningOfDay, endOfDay, nextHalfHour, sunday
	}

	
	// MARK: - Date algebra and manipulation
	
	var dayWeekMonthYearComponents: DateComponents {
		return calendar.dateComponents([.day, .weekOfMonth, .month, .year], from: self)
	}
	
	func aligned(to timePeriod: TimePeriod, with timeZone: TimeZone) -> Date? {
		calendar.timeZone = timeZone
		
		switch timePeriod {
		case .beginningOfDay:
			return calendar.startOfDay(for: self)
			
		case .endOfDay:
			return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)
			
		case .nextHalfHour:
			let currentMinuteComponent = calendar.component(.minute, from: self)
			// If date is already aligned, don't change anything
			guard currentMinuteComponent != 30 && currentMinuteComponent != 0 else {
				return self
			}
			
			let nextHalfHourMark = currentMinuteComponent < 30 ? 30 : 60
			return advance(.minute, by: nextHalfHourMark - currentMinuteComponent, in: timeZone)
			
		case .sunday:
			// 1 - sunday, 7 - saturday
			return calendar.date(bySetting: .weekday, value: 1, of: self)
		}
	}
	
	func advance(_ component: Calendar.Component, by value: Int, in timeZone: TimeZone) -> Date? {
		calendar.timeZone = timeZone
		return calendar.date(byAdding: component, value: value, to: self)
	}
	
	func isSame(_ granularity: Calendar.Component, as other: Date) -> Bool {
		return calendar.compare(self, to: other, toGranularity: granularity) == .orderedSame
	}
	
	static func from(iso8601String: String?) -> Date? {
		guard let iso8601String = iso8601String else { return nil }
		return iso8601DateFormatter.date(from: iso8601String)
	}
	
	/// Example: string: "2018-12-25", format: "yyyy-mm-dd"
	static func from(string: String?, withFormat format: String?) -> Date? {
		guard let string = string else { return nil }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.date(from: string)
	}
	
	
	// MARK: - Formatters
	
	var iso8601GMT: String {
		return iso8601DateFormatter.string(from: self)
	}
	
	/// - Jun 24, 2018, 5:21 PM
	func shortMonthDayYearTimeString(in timeZone: TimeZone) -> String {
		return _format(with: [.monthShort, .dayOfMonth, .yearFull, .hour, .minute], in: timeZone)
	}
	
	/// - Jun 24, 2018
	func shortMonthDayYearFormat(in timeZone: TimeZone) -> String {
		return _format(with: [.monthShort, .dayOfMonth, .yearFull], in: timeZone)
	}
	
	/// - April 2018
	func fullMonthYearFormat(in timeZone: TimeZone) -> String {
		return _format(with: [.monthFull, .yearFull], in: timeZone)
	}
	
	/// - Sun, Jun 24, 12:00 AM
	func shortWeekdayMonthDayTimeString(in timeZone: TimeZone) -> String {
		return _format(with: [.weekdayShort, .monthShort, .dayOfMonth, .hour, .minute], in: timeZone)
	}
	
	/// - Sun, Jun 24
	func shortWeekdayMonthDayString(in timeZone: TimeZone) -> String {
		return _format(with: [.weekdayShort, .monthShort, .dayOfMonth], in: timeZone)
	}
	
	// - Sunday, June 24
	func fullWeekdayMonthDayString(in timeZone: TimeZone) -> String {
		return _format(with: [.weekdayFull, .monthFull, .dayOfMonth], in: timeZone)
	}
	
	/// - Jun 24
	func shortMonthDayFormat(in timeZone: TimeZone) -> String {
		return _format(with: [.monthShort, .dayOfMonth], in: timeZone)
	}
	
	/// - 2:00 PM/14:00 (depending on the locale)
	func timeString(in timeZone: TimeZone) -> String {
		return _format(with: [.hour, .minute], in: timeZone)
	}
	
	/// Localized time range, removing the first period if locale uses 12 hour format and the periods are the same.
	/// - 1:00 - 2:30 PM
	/// - 10:30 AM - 1 PM
	/// - 10:30 - 13:00 (24 hour format)
	func compactTimeRange(to rightDate: Date, separator: String, in timeZone: TimeZone) -> String {
		dateFormatter.timeZone = timeZone
		
		var rightComponents: [DateFormatComponents] = [.hour, .minute]
		if (timeZone != .current) {
			rightComponents.append(DateFormatComponents.timeZone)
		}
		
		let leftFormat = _dateFormat(with: [.hour, .minute])
		let rightFormat = rightDate._dateFormat(with: rightComponents)
		
		return _compactPeriodsIfPossibleWith(
			otherDate: rightDate,
			leftFormat: leftFormat,
			rightFormat: rightFormat,
			separator: separator,
			in: timeZone)
	}
	
	/// Returns short weekday, month day and year, unless it's the current year.
	/// - Sun, Jun 24
	/// - Sun, Jun 24, 2019
	func compactShortDateString(in timeZone: TimeZone) -> String {
		guard isSame(.year, as: Date()) else {
			return _format(with: [.weekdayShort, .monthShort, .dayOfMonth, .yearFull], in: timeZone)
		}
		
		return _format(with: [.weekdayShort, .monthShort, .dayOfMonth], in: timeZone)
	}
	
	/// Returns short weekday, month day and year and time, unless it's the current year.
	/// - Sun, Jun 24, 12:00 AM
	/// - Sun, Jun 24, 2020, 12:00 AM
	func compactShortDateTimeString(in timeZone: TimeZone) -> String {
		guard isSame(.year, as: Date()) else {
			return _format(with: [.weekdayShort, .monthShort, .dayOfMonth, .yearFull, .hour, .minute], in: timeZone)
		}
		
		return _format(with: [.weekdayFull, .monthShort, .dayOfMonth, .hour, .minute], in: timeZone)
	}
	
	/// Returns localized compact date range, ommitting the minutes and/or the period when appropriate.
	/// - Jun 30, 2018, 10:00 - 11:30 AM
	/// - Jun 30, 2018 10:00 PM - Jul 1, 1:00 AM
	/// - Dec 31, 2018 10:05 PM - Jan 1, 2019, 2:00 AM
	func compactFullDateTimeRange(to rightDate: Date, separator: String, in timeZone: TimeZone) -> String {
		var rightComponents: [DateFormatComponents] = []
		
		if isSame(.day, as: rightDate) {
			rightComponents = [.hour, .minute]
			
		} else if isSame(.year, as: rightDate) {
			rightComponents = [.monthShort, .dayOfMonth, .hour, .minute]
			
		} else {
			rightComponents = [.yearFull, .monthShort, .dayOfMonth, .hour, .minute]
		}
		
		if (timeZone != .current) {
			rightComponents.append(DateFormatComponents.timeZone)
		}
		
		let leftFormat = isSame(.year, as: Date())
			? _dateFormat(with: [.monthShort, .dayOfMonth, .hour, .minute])
			: _dateFormat(with: [.monthShort, .dayOfMonth, .yearFull, .hour, .minute])
		let rightFormat = _dateFormat(with: rightComponents)
		
		return _compactPeriodsIfPossibleWith(
			otherDate: rightDate,
			leftFormat: leftFormat,
			rightFormat: rightFormat,
			separator: separator,
			in: timeZone)
	}
	
	/// - `Today` (if today's date) or `Sun, Jun 24`
	func localizedWeekdayMonthDay(in timeZone: TimeZone) -> String {
		guard !isSame(.day, as: Date()) else { return "common_today".localized }
		return _format(with: [.monthShort, .dayOfMonth, .weekdayShort], in: timeZone)
	}
	
	/// - 24/05/2018 (depending on the locale)
	func digitDayMonthYearFull(in timeZone: TimeZone) -> String {
		return _format(with: [.dayOfMonth, .monthDigit, .yearFull], in: timeZone)
	}
	
	/// - 24/05/18 (depending on the locale)
	func shortTicketDateString(in timeZone: TimeZone) -> String {
		return _format(with: [.dayOfMonth, .monthDigit, .yearShort], in: timeZone)
	}
}


// MARK: - Helper Functions

fileprivate extension Date {
	func _format(with components: [DateFormatComponents], in timeZone: TimeZone) -> String {
		var components = components
		
		// If the timeZone is different than the default (current timeZone on this device, add it to the format).
		if (timeZone != .current
			&& !components.contains(DateFormatComponents.timeZone)
			&& components.contains(DateFormatComponents.hour)) {
			components.append(DateFormatComponents.timeZone)
		}
	
		dateFormatter.timeZone = timeZone
		dateFormatter.dateFormat = _dateFormat(with: components)
		
		return dateFormatter.string(from: self)
	}
	
	func _dateFormat(with components: [DateFormatComponents]) -> String {
		let joinedComponents = components.map { $0.rawValue }.joined()
		guard let format = DateFormatter.dateFormat(fromTemplate: joinedComponents, options: 0, locale: .current),
			!format.isEmpty
			else {
				// If something breaks (it shouldn't), return a full date/time format, e.g. `MMM d, y 'at' h:mm a`
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .short
				return dateFormatter.dateFormat
		}
		
		return format
	}
	
	func _compactPeriodsIfPossibleWith(
		otherDate: Date,
		leftFormat: String,
		rightFormat: String,
		separator: String,
		in timeZone: TimeZone) -> String {
		var leftFormatCopy = leftFormat
		
		let leftHour = calendar.component(.hour, from: self)
		let rightHour = calendar.component(.hour, from: otherDate)
		
		// Don't remove the period if not the same day or different periods
		let cantCompact = !isSame(.day, as: otherDate)
			|| (leftHour < 12 && rightHour >= 12)
			|| (leftHour >= 12 && rightHour < 12)
		
		let formatsHaveTwoPeriods = leftFormatCopy.contains(" a") && rightFormat.contains(" a")
		if !cantCompact && formatsHaveTwoPeriods, let leftPeriodRange = leftFormatCopy.range(of: " a") {
			leftFormatCopy.removeSubrange(leftPeriodRange)
		}
		
		dateFormatter.timeZone = timeZone
		dateFormatter.dateFormat = leftFormatCopy
		let leftDate = dateFormatter.string(from: self)
		
		dateFormatter.dateFormat = rightFormat
		let rightDate = dateFormatter.string(from: otherDate)
		
		return "\(leftDate) \(separator) \(rightDate)"
	}
}
