import Foundation

fileprivate struct AssociatedKeys {
	static var debugLoggingEnabled: UInt8 = 0
}

public extension NSObject {

	// MARK: - Properties
	
	var debugLoggingEnabled: Bool {
		get { return objc_getAssociatedObject(self, &AssociatedKeys.debugLoggingEnabled) as? Bool ?? false }
		set {
			objc_setAssociatedObject(
				self,
				&AssociatedKeys.debugLoggingEnabled,
				newValue,
				objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
		}
	}


	// MARK: - Functions

	func log(_ level: LogLevel, _ messageFormat: @autoclosure @escaping () -> String, _ args: CVarArg...) {
		if debugLoggingEnabled {
			Logger.defaultLogger.log(level, messageFormat(), args)
		}
	}
}
