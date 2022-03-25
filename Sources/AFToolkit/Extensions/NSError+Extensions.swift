import Foundation

public extension NSError {
	
	// MARK: - Inits
	
	convenience init(_ userInfo: [String: String], withCode code: Int, log: Bool) {
		// Log any error created by this function, if requested.
		if log {
			Logger.defaultLogger.log(.error, "CODE: \(code) REASON: \(userInfo[NSLocalizedDescriptionKey] ?? "")")
		}

		// Use the bundle display name as the error domain.
		let bundle = Bundle.main
		let info = bundle.infoDictionary
		let bundleDisplayName = info?[kCFBundleNameKey as String] as? String ?? ""

		// Create the error.
		self.init(domain: bundleDisplayName, code: code, userInfo: userInfo)
	}
	
	convenience init(_ localizedDescription: String, withCode code: Int = -1, log: Bool = true) {
		let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
		self.init(userInfo, withCode: code, log: log)
	}
	
	
	// MARK: - Functions
	
	static func error(
		_ localizedDescription: String,
		withCode code: Int = -1,
		 log: Bool = true) -> NSError {
		return NSError(localizedDescription, withCode: code, log: log)
	}
}
