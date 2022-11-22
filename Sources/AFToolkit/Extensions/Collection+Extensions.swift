import Foundation

extension Collection {
	// Returns `nil` if the collection is empty.
	var nonEmpty: Self? {
		guard !isEmpty else { return nil }
		return self
	}
}
