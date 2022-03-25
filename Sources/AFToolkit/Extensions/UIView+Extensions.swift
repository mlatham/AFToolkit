import Foundation
import UIKit

public extension UIView {
	
	// MARK: - Functions
	
	var firstAvailableViewController: UIViewController? {
		return UIView._traverseResponderChainForViewController(from: self)
	}
	
	func presentViewController(_ controller: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
		guard let viewController = firstAvailableViewController else {
			log(.debug, "Couldn't find parent view controller")
			return
		}
		
		viewController.present(controller, animated: animated, completion: completion)
	}
	
	
	// MARK: - Helpers
	
	private static func _traverseResponderChainForViewController(from responder: UIResponder) -> UIViewController? {
		if let responder = responder as? UIViewController {
			return responder
		} else if let nextResponder = responder.next {
			return _traverseResponderChainForViewController(from: nextResponder)
		}
		return nil
	}
}
