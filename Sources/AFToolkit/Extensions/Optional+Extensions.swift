
/// Wrapper protocol type for Optional enum.
/// Conforming Optional to this lets us avoid specifying the generic Wrapped type for extensions.
public protocol OptionalType: ExpressibleByNilLiteral {
	associatedtype Wrapped
	var optional: Wrapped? { get }
}

/// A type-erased, non-generic optional protocol that can be used for casting `as? AnyOptional`.
public protocol AnyOptional {
	var isNil: Bool { get }
}
