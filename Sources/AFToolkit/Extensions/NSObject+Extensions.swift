import Foundation

fileprivate struct AssociatedKeys {
	static var selfLogEnabled: UInt8 = 0
}

public extension NSObject {

	// MARK: - Properties
	
	var selfLogEnabled: Bool {
		get { return objc_getAssociatedObject(self, &AssociatedKeys.selfLogEnabled) as? Bool ?? false }
		set {
			objc_setAssociatedObject(
				self,
				&AssociatedKeys.selfLogEnabled,
				newValue,
				objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
		}
	}


	// MARK: - Functions

	// Instance-level log statements.
	func selfLog(_ level: Logger.Level, _ messageFormat: @autoclosure @escaping () -> String, _ args: CVarArg...) {
		if selfLogEnabled {
			Logger.defaultLogger.log(level, messageFormat(), args)
		}
	}
}
