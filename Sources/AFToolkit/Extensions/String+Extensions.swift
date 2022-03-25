import UIKit

public extension String {

	// MARK: - Functions

	func localizedWithComment(_ comment: String) -> String {
		let message = NSLocalizedString(self, comment: comment)
		
		if message != self {
            return message
        }
		
		// Use english as a fallback.
		let language = "en"
		let path = Bundle.main.path(forResource: language, ofType: "lproj")
		let bundle = Bundle(path: path!)
		if let forcedString = bundle?.localizedString(forKey: self, value: nil, table: nil) {
			return forcedString
		} else {
			return self
		}
	}

	var localized: String {
		return localizedWithComment("")
	}
}
