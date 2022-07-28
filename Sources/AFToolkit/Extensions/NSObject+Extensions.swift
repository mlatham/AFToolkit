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
	
	// Defers calling a selector on this object for a period of time to batch together tight
	// bursts of function calls into periodic calls.
	func performDeduped(_ selector: Selector, delay: TimeInterval = 0.5) {
		// Cancel any previous request.
		NSObject.cancelPreviousPerformRequests(
			withTarget: self,
			selector: selector,
			object: nil)
		
		// Queue up a perform.
		perform(selector, with: nil, afterDelay: delay)
	}
	
	// Synchronizes on this object, then calls the provided closure.
	func synchronized(_ closure: VoidClosure) {
		objc_sync_enter(self)
		closure()
		objc_sync_exit(self)
	}
}
