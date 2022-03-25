import SnapKit
import UIKit

public extension ConstraintMakerExtendable {
	
	// MARK: - Functions
	
	@discardableResult
	func equalToTopGuide(_ controller: UIViewController) -> ConstraintMakerEditable {
		if #available(iOS 11.0, *) {
			return equalTo(controller.view.safeAreaLayoutGuide.snp.top)
		} else {
			// TODO: DEPRECTATE:
			return equalTo(controller.topLayoutGuide.snp.top)
		}
	}
	
	@discardableResult
	func equalToBottomGuide(_ controller: UIViewController) -> ConstraintMakerEditable {
		if #available(iOS 11.0, *) {
			return equalTo(controller.view.safeAreaLayoutGuide.snp.bottom)
		} else {
			// TODO: DEPRECATE:
			return equalTo(controller.bottomLayoutGuide.snp.bottom)
		}
	}
}
