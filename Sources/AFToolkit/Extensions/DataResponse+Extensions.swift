import Foundation
import Alamofire

public extension DataResponse {

	// MARK: - Enums

	enum DescriptionOptions {
		case request, requestHeaders, requestBody, response, responseHeaders, duration, result
	}
	
	
	// MARK: - Functions
	
	func prettyDescription(
		options: Set<DescriptionOptions> = [
			.request,
			//.requestHeaders,
			//.requestBody,
			.response,
			.responseHeaders,
			//.duration,
			.result
			])
		-> String {
		guard let urlRequest = request else { return "REQUEST: None\nRESULT: \(result)" }

        let requestDescription = DebugDescription.description(
			of: urlRequest,
			includeHeaders: options.contains(.requestHeaders),
			includeBody: options.contains(.requestBody))

        let responseDescription = response.map { response in
            let responseBodyDescription = DebugDescription.description(for: data, headers: response.headers)

            return """
            \(DebugDescription.description(of: response, includeHeaders: options.contains(.responseHeaders)))
            \(responseBodyDescription)
            """
        } ?? "RESPONSE: None"

		let networkDuration = metrics.map { $0.taskInterval.duration } ?? -1

		var description = ""
		if (options.contains(.request)) {
			description.append(requestDescription)
		}
		if (options.contains(.response)) {
			description.append(responseDescription)
		}
		if (options.contains(.duration)) {
			var durationHint = "FAST"
			if (networkDuration > 6) {
				durationHint = "SLOW"
			}
			else if (networkDuration > 3) {
				durationHint = "MODERATE"
			}
			description = description.appendingFormat(
				"\nDURATION: %.3fs (\(durationHint))\nSERIALIZATION DURATION: %.3fs",
				networkDuration,
				serializationDuration)
		}
		if (options.contains(.result)) {
			description.append("\nRESULT: \(self.result)")
		}
		return description
	}
}


// MARK: - Helpers

/// ATTRIBUTION: Adapted from Alamofire DebugDescription.
private enum DebugDescription {
    static func description(of request: URLRequest, includeHeaders: Bool, includeBody: Bool) -> String {
		var result = "\nREQUEST: \(request.httpMethod!) \(request)"
		
		if (includeHeaders) {
			result.append("\n\t\(DebugDescription.description(for: request.headers).indentingNewlines())")
		}
		
		if (includeBody) {
			result.append("\n\t\(DebugDescription.description(for: request.httpBody, headers: request.headers))")
		}
        
        return result
    }

    static func description(of response: HTTPURLResponse, includeHeaders: Bool) -> String {
		var result = "\nRESPONSE: STATUS \(response.statusCode)"
		
		if (includeHeaders) {
			result.append("\n\t\(DebugDescription.description(for: response.headers).indentingNewlines())")
		}
		
		return result
    }

    static func description(for headers: HTTPHeaders) -> String {
        guard !headers.isEmpty else { return "HEADERS: None" }

		return "HEADERS:\("\n\(headers.sorted())".indentingNewlines(by: 1))"
    }

    static func description(
		for data: Data?,
		headers: HTTPHeaders,
		allowingPrintableTypes printableTypes: [String] = ["json", "xml", "text"],
		maximumLength: Int = 100_000) -> String {
        guard var data = data, !data.isEmpty else { return "BODY: None" }

        guard data.count <= maximumLength,
			let contentType = headers["Content-Type"],
			printableTypes.compactMap({ contentType.contains($0) }).contains(true)
        else { return "BODY: \(data.count) bytes" }
        
        // Pretty-print JSON - this parses the JSON data, then converts back to a string to print with indentation.
        if contentType.contains("json") {
			if let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
				JSONSerialization.isValidJSONObject(object) {
				data = (try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)) ?? data
			}
		}

        return "BODY:\n\(String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines))"
    }
}

fileprivate extension String {
    func indentingNewlines(by tabCount: Int = 1) -> String {
        let tabs = String(repeating: "\t", count: tabCount)
        return replacingOccurrences(of: "\n", with: "\n\(tabs)")
    }
}
