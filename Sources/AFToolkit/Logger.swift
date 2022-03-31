import Foundation


// MARK: - Enums

public class Logger {
	
	// MARK: - Enums
	
	public enum Level {
		case debug
		case error
		case info
	}


	// MARK: - Properties

	public static let defaultLogger = Logger()
	
	#if DEBUG
	public var debugLoggingEnabled: Bool = true
	#else
	public var debugLoggingEnabled: Bool = false
	#endif
	
	
	// MARK: - Functions

	public func log(_ level: Level, _ messageFormat: @autoclosure @escaping () -> String, _ args: CVarArg...) {
		// Skip logging, if disabled.
		if debugLoggingEnabled {
			// Use a nested function to present a "curried" function with only one
			// argument so we can pass it to withVaList.
			func curriedStringWithFormat(_ valist: CVaListPointer) -> String {
				// We capture the messageFormat closure and call it when creating
				// the formatted string.
				return NSString(format: messageFormat(), arguments: valist) as String
			}

			// Construct a new string that inserts the format statement.
			var linePrefix = "DEBUG   "
			switch (level) {
			case .debug:
				linePrefix = "🌀 DEBUG   "
				break

			case .error:
				linePrefix = "🔥 ERROR   "
				break

			case .info:
				linePrefix = "⚠️ WARN    "
				break
			}

			// Call the curried function with a va_list
			let s = withVaList(args, curriedStringWithFormat)

			// Print using a special format.
			print("\(linePrefix): \(s)")
		}
	}
}
