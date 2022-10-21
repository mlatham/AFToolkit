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
	
	func scrollToTop() {
		// Guards against a crash if there are no sections in the tableview.
		let countOfSections = numberOfSections
		guard countOfSections > 0 else { return }
	
		// Guards against a crash if there are no rows in the tableview.
		let countOfRows = numberOfRows(inSection: 0)
		guard countOfRows > 0 && countOfRows != NSNotFound else { return }
		
		// Creates an invalid IndexPath that makes the tableview scroll to the top
		let indexPath = IndexPath(row: NSNotFound, section: 0)
		scrollToRow(at: indexPath, at: .top, animated: true)
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
		
		if #available(iOS 15.0, *) {
			// Remove default top padding.
			sectionHeaderTopPadding = 0
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
