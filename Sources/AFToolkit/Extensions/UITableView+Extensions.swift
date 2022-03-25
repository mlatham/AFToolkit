import Foundation
import UIKit

public extension UITableView {

	// MARK: - Functions

	func dequeueReusableCell<T: UITableViewCell>(_ returningType: T.Type) -> T {
		let identifier = String(describing: returningType)
		
		return dequeueReusableCell(returningType, withIdentifier: identifier)
	}
	
	func dequeueReusableCell<T: UITableViewCell>(
		_ returningType: T.Type,
		withIdentifier identifier: String) -> T {
		
		if let cell = dequeueReusableCell(withIdentifier: identifier) as? T {
			return cell
			
		} else {
			// Use the metatype to explicitly init the type of the cell passed in.
			return returningType.init(style: .default, reuseIdentifier: identifier)
		}
	}
	
	func dequeueReusableSectionView<T: UITableViewHeaderFooterView>(_ returningType: T.Type) -> T {
		let identifier = String(describing: returningType)
		
		return dequeueReusableSectionView(returningType, withIdentifier: identifier)
	}
	
	func dequeueReusableSectionView<T: UITableViewHeaderFooterView>(
		_ returningType: T.Type,
		withIdentifier identifier: String) -> T {
		
		if let header = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T {
			return header
		} else {
			return returningType.init(reuseIdentifier: identifier)
		}
	}

	func applyDynamicSizing(rowHeight: CGFloat? = nil, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil) {
		if let rowHeight = rowHeight {
			estimatedRowHeight = rowHeight
			self.rowHeight = UITableView.automaticDimension
		}
		if let headerHeight = headerHeight {
			estimatedSectionHeaderHeight = headerHeight
			sectionHeaderHeight = UITableView.automaticDimension
		}
		if let footerHeight = footerHeight {
			estimatedSectionFooterHeight = footerHeight
			sectionFooterHeight = UITableView.automaticDimension
		}
	}
	
	func applyStaticSizing(rowHeight: CGFloat? = nil, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil) {
		if let rowHeight = rowHeight {
			// This fixes weird tableView refresh when the top most cell is only partially visible.
			estimatedRowHeight = 0
			self.rowHeight = rowHeight
		}
		if let headerHeight = headerHeight {
			estimatedSectionHeaderHeight = 0
			sectionHeaderHeight = headerHeight
		}
		if let footerHeight = footerHeight {
			estimatedSectionFooterHeight = 0
			sectionFooterHeight = footerHeight
		}
	}
}
