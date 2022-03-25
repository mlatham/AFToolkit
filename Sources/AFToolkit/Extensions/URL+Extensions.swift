import Foundation

public extension URL {
	
	// MARK: - Functions
	
	/// Gets this URL's query parameters.
	var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
            else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    /// Gets this URL, minus the query.
    var urlWithoutQuery: URL? {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
			return self
		}
		components.query = nil
		return components.url
	}
}
