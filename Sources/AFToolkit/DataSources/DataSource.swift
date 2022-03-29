import UIKit

public typealias BaseCell = CellConfigurable & UITableViewCell
public protocol CellConfigurable {
	associatedtype Item
	static var EstimatedHeight: CGFloat { get }
	func configure(with item: Item)
	func deselected()
	func selected()
}

public typealias TableViewDataSource = UITableViewDataSource & UITableViewDelegate

/// Delegate that allows the data source to manage its own data collection, then
/// call back to notify the UI to call reloadData on its table view.
/// MATT NOTES: This pattern can be used for data sources on reducer states, however
/// when the data source's models are updated, newState should stand in place of the
/// delegate reloadData(). Those data sources will always return the defaultCellType.
public protocol DataSourceDelegate: AnyObject {
	func reloadData()
}

/// A data source with a unsectioned items. TODO: Restructure this to be an immutable struct.
public class DataSource<Cell: BaseCell, EmptyCell: BaseCell>: NSObject, TableViewDataSource {
	
	public typealias DequeueCellClosure = (_ tableView: UITableView, _ item: Cell.Item) -> Cell
	
	
	// MARK: - Properties

	private(set) var dequeueCellClosure: DequeueCellClosure
	
	private(set) var emptyItem: EmptyCell.Item
	private(set) var needsSetItems: Bool = true
	private(set) var items: [Cell.Item] = []
	
	public weak var delegate: DataSourceDelegate?
	
	public var isEmpty: Bool {
		return !needsSetItems && items.count == 0
	}
	
	
	// MARK: - Inits
	
	public init(
		dequeueCellClosure: @escaping DequeueCellClosure = { tableView, item in
			return tableView.dequeueReusableCell(Cell.self)
		},
		emptyItem: EmptyCell.Item,
		delegate: DataSourceDelegate? = nil) {
		self.dequeueCellClosure = dequeueCellClosure
		self.emptyItem = emptyItem
		self.delegate = delegate
		super.init()
	}
	
	
	// MARK: - Functions
	
	public func reset() {
		items = []
		
		needsSetItems = true
		
		delegate?.reloadData()
	}
	
	public func setItems(_ items: [Cell.Item]) {
		self.items = items
		
		needsSetItems = false
		
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
		tableView.applyDynamicSizing(rowHeight: Cell.EstimatedHeight)
	}
	

	// MARK: - UITableView Functions

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isEmpty ? 1 : items.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Empty state returns a single cell.
		guard !isEmpty else {
			let cell = tableView.dequeueReusableCell(EmptyCell.self)
			cell.configure(with: emptyItem)
			return cell
		}
		
		let item = items[indexPath.row]
		
		let cell = dequeueCellClosure(tableView, item)
		cell.configure(with: item)

		selfLog(.debug, "\(Cell.self) height: \(cell.frame.size.height)")

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
