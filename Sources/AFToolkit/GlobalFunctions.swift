import Foundation
import UIKit

// Includes global (non-static, non-class) functions. These are functions that might be helpful to inline into
// projects as needed, and so would be messy to refactor if namespaced under a class.

/// A function to create, customize and return an object.
///
/// Example:
/// let label = Init(UILabel()) {
///   $0.font = ...
///   $0.textColor = ...
/// }
public func Init<Type>(_ object: Type, _ customize: (Type) -> Void) -> Type {
  customize(object)
  return object
}

/// A function to create, customize and map to a different object.
///
/// Example:
/// let collectionView: UICollectionView = MapInit(UICollectionViewFlowLayout()) {
///   $0.minimumLineSpacing = ...
///   return UICollectionView(frame: .zero, collectionViewLayout: $0)
/// }
public func MapInit<Type, Result>(_ object: Type, _ customize: (Type) -> Result) -> Result {
  return customize(object)
}

/// Global logging function.
public func afLog(_ level: Logger.Level, _ messageFormat: @autoclosure @escaping () -> String, _ args: CVarArg...) {
	Logger.defaultLogger.log(level, messageFormat(), args)
}

public func x(_ gridUnits: Float) -> CGFloat {
	return CGFloat(Float(UT.Style.gridUnitSize) * gridUnits)
}
