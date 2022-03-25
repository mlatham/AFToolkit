import Foundation

// TODO: MATT: Clean this up and make it mine.

//// HACK: - iOS 12 doesn't support top-level type encoding/decoding, which breaks preferences backed by enum types.
//// The temporary workaround below is a PreferenceStorable protocol that defines an interface to encode/decode values
//// appropriately for preferences, which is specialized by other protocols for each specific use case.
//// TODO: - When iOS 14 is released and iOS 13 is the minimum version, this can be safely removed and the generic
//// `Value` can be constrained back to `Codable`.
//
//protocol PreferenceStorable {
//	var encodedValue: Any? { get }
//	static func decoded(from value: Any?) -> Self?
//}
//
//// Default implementation for primitive types. Nothing needs to be done to the value - they're written and casted as is.
//extension PreferenceStorable {
//	var encodedValue: Any? {
//		return self
//	}
//	static func decoded(from value: Any?) -> Self? {
//		return value as? Self
//	}
//}
//
//// Default implementation for RawRepresentable (enum) types. Raw value is what's written to preferences in this case.
//protocol RawRepresentablePreference: PreferenceStorable, RawRepresentable { }
//extension RawRepresentablePreference {
//	var encodedValue: Any? {
//		return self.rawValue
//	}
//	static func decoded(from value: Any?) -> Self? {
//		guard let rawValue = value as? RawValue else { return nil }
//		return Self.init(rawValue: rawValue)
//	}
//}
//
//// Default implementation for Codable classes/structs, which are encoded into json when written to preferences.
//protocol PreferenceCodable: PreferenceStorable, Codable { }
//extension PreferenceCodable {
//	var encodedValue: Any? {
//		return self.encoded()
//	}
//	static func decoded(from value: Any?) -> Self? {
//		return Self.decode(usingData: value as? Data)
//	}
//}
//
//// Primitive types.
//extension Bool: PreferenceStorable { }
//extension Double: PreferenceStorable { }
//extension String: PreferenceStorable { }
//extension Date: PreferenceStorable { }
//extension Int32: PreferenceStorable { }
//extension Array: PreferenceStorable where Element: PreferenceStorable { }
//extension Optional: PreferenceStorable where Wrapped: PreferenceStorable { }

@propertyWrapper
public struct Preference<Value: Codable> {
	
	// MARK: - Properties
	
	private var _debugLoggingEnabled = false
	
	public let key: String
	public let defaultValue: Value
	public var wrappedValue: Value {
		get {
			let storedValue = UserDefaults.standard.object(forKey: key)
			
			guard let data = storedValue as? Data else {
				// If that fails, try to cast the value to the intended type directly, or fall back to the default.
				return storedValue as? Value ?? defaultValue
			}
			
			return Value.decode(usingData: data) ?? defaultValue
		}
		set {
			let userDefaults = UserDefaults.standard
			
			if let optionalValue = newValue as? AnyOptional, optionalValue.isNil {
				userDefaults.removeObject(forKey: key)
				return
			}
			
			let encodedValue = newValue.encoded()
			
			if _debugLoggingEnabled {
				let key = self.key
				Logger.defaultLogger.log(.debug, "Preferences[\(key)] = \(String(describing: newValue))")
			}
			
			// Set the encoded value directly, with a fallback to the raw value directly.
			userDefaults.set(encodedValue ?? newValue, forKey: key)
		}
	}
	
	
	// MARK: - Inits
	
	public init(_ key: String, defaultValue: Value) {
		self.key = key
		self.defaultValue = defaultValue
	}
}


// Allow initialization without a default value for optional types.
public extension Preference where Value: OptionalType {
	init(_ key: String) {
		self.key = key
		self.defaultValue = nil
	}
}
