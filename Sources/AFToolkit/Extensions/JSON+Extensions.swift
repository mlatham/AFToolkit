import Foundation

public extension Encodable {
	
	// MARK: - Functions
	
	func encoded(
		using dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(DateFormatter.iso8601),
		keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase) -> Data? {
		let jsonEncoder = JSONEncoder()
		jsonEncoder.dateEncodingStrategy = dateEncodingStrategy
		jsonEncoder.keyEncodingStrategy = keyEncodingStrategy
		
		do {
			return try jsonEncoder.encode(self)
			
		} catch let error {
			afLog(.error, "\(error)")
			return nil
		}
	}
	
	func toDictionary(
		using dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(DateFormatter.iso8601),
		keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase) -> [String: Any]? {
		guard let data = self.encoded(using: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy) else {
			return nil
		}
		
		guard let dictionary = try? JSONSerialization
			.jsonObject(with: data, options: .allowFragments) as? [String: Any]
			else { return nil }

		return dictionary
	}
	
	var jsonString: String? {
		guard let data = encoded() else { return nil }
		return String(data: data, encoding: .utf8)
	}
}

public extension Decodable {
	
	// MARK: - Functions
	
	/// Deserializes the provided object to JSON bytes, then decodes the data to Decodable models.
	static func decode(
		usingJsonData jsonData: Any?,
		dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601),
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) -> Self? {
		
		guard let jsonData = jsonData else { return nil }
		
		do {
			guard JSONSerialization.isValidJSONObject(jsonData) else {
				afLog(.error, "Invalid JSON: \(jsonData)")
				return nil
			}
			let data = try JSONSerialization.data(withJSONObject: jsonData, options: [])
			let model = decode(
				usingData: data,
				dateDecodingStrategy: dateDecodingStrategy,
				keyDecodingStrategy: keyDecodingStrategy)
			return model
			
		} catch let error {
			afLog(.error, "\(error)")
			return nil
		}
	}
	
	/// Decodes the provided JSON bytes to Decodable models.
	static func decode(
		usingData data: Data?,
		dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601),
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) -> Self? {
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
		jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
		
		guard let data = data else { return nil }
		
		do {
			return try jsonDecoder.decode(Self.self, from: data)
			
		} catch let error {
			afLog(.error, "\(error)")
			return nil
		}
	}
}

public extension KeyedDecodingContainer {

	// MARK: - Functions

	/// Decodes and sets a value from a container.
	/// 
	/// Example:
	///
	/// class MyClass: Codable {
	///		private enum CodingKeys: String, CodingKey { case myProperty }
	///		var myProperty: String? = nil
	///
	/// 	init(from decoder: Decoder) throws {
	/// 		let values = try decoder.container(keyedBy: CodingKeys.self)
	///			values.set(&self, path: \MyClass.myProperty, key: .myProperty)
	/// 	}
	/// }
	func set<Root, Value>(
		_ into: inout Root,
		path: WritableKeyPath<Root, Value?>,
		key: K,
		defaultValue: Value? = nil) where Value: Decodable {
		into[keyPath: path] = (try? decode(Value.self, forKey: key)) ?? defaultValue
	}
}
