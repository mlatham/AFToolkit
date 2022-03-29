import UIKit

/// Holder object for sectioned data.
public protocol BaseSection {
	associatedtype Item
	var items: [Item] { get }
}

public typealias BaseSectionView = SectionViewConfigurable & UITableViewHeaderFooterView
public protocol SectionViewConfigurable {
	associatedtype Section: BaseSection where Section.Item == Item
	associatedtype Item
	static var EstimatedHeight: CGFloat { get }
	func configure(with section: Section)
}

/// A data source with sectioned items.
public class SectionedDataSource<SectionView: BaseSectionView, Cell: BaseCell, EmptyCell: BaseCell>:
	NSObject,
	TableViewDataSource
	where SectionView.Item == Cell.Item {
	
	public typealias DequeueSectionViewClosure = (_ tableView: UITableView, _ section: SectionView.Section) -> SectionView
	public typealias DequeueCellClosure = (_ tableView: UITableView, _ item: SectionView.Item) -> Cell


	// MARK: - Properties
	
	public private(set) var dequeueSectionViewClosure: DequeueSectionViewClosure
	public private(set) var dequeueCellClosure: DequeueCellClosure
	
	public private(set) var emptyItem: EmptyCell.Item
	public private(set) var needsSetSections: Bool = true
	public private(set) var sections: [SectionView.Section] = []
	
	public weak var delegate: DataSourceDelegate?
	
	public var isEmpty: Bool {
		return !needsSetSections && !sections.contains { $0.items.count > 0 }
	}
	
	
	// MARK: - Inits
	
	public init(
		dequeueSectionViewClosure: @escaping DequeueSectionViewClosure = { tableView, section in
			return tableView.dequeueReusableSectionView(SectionView.self)
		},
		dequeueCellClosure: @escaping DequeueCellClosure = { tableView, item in
			return tableView.dequeueReusableCell(Cell.self)
		},
		emptyItem: EmptyCell.Item,
		delegate: DataSourceDelegate? = nil) {
		self.dequeueSectionViewClosure = dequeueSectionViewClosure
		self.dequeueCellClosure = dequeueCellClosure
		self.emptyItem = emptyItem
		self.delegate = delegate
		super.init()
	}
	
	
	// MARK: - Functions
	
	public func reset() {
		sections = []
		
		needsSetSections = true
		
		delegate?.reloadData()
	}
	
	public func setSections(_ sections: [SectionView.Section]) {
		self.sections = sections
		
		needsSetSections = false
		
		delegate?.reloadData()
	}
	
	public func apply(to tableView: UITableView) {
		guard tableView.dataSource !== self || tableView.delegate !== self else {
			return
		}
		
		tableView.dataSource = self
		tableView.delegate = self
		// Remove the default cell separators.
		tableView.separatorStyle = .none
		tableView.applyDynamicSizing(rowHeight: Cell.EstimatedHeight, headerHeight: SectionView.EstimatedHeight)
	}
	
	
	// MARK: - UITableView Functions
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return isEmpty ? 1 : sections.count
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isEmpty ? 1 : sections[section].items.count
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		// Empty state. NOTE: Returning a view here returns an empty / zero height header.
		guard !isEmpty else {
			return UIView()
		}
	
		let section = sections[section]
		
		let sectionView = dequeueSectionViewClosure(tableView, section)
		
		sectionView.configure(with: section)
		
		selfLog(.debug, "\(SectionView.self) height: \(sectionView.frame.size.height)")
		
		return sectionView
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Empty state returns a single cell.
		guard !isEmpty else {
			let cell = tableView.dequeueReusableCell(EmptyCell.self)
			cell.configure(with: emptyItem)
			return cell
		}
		
		let item = sections[indexPath.section].items[indexPath.row]
		
		let cell = dequeueCellClosure(tableView, item)
		
		cell.configure(with: item)
		
		if selfLogEnabled {
			selfLog(.debug, "\(Cell.self) height: \(cell.frame.size.height)")
		}

		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { return }
		cell.selected()
	}
	
	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { return }
		cell.deselected()
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Abstract
	}
}
