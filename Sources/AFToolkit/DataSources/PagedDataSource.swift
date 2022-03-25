import Foundation
import UIKit

/// Represents the state of a data source that can incrementally load data. This applies to both
/// UNPagedDataSource and UNPagedSectionedDataSource.
public enum PagedDataSourceState {
	/// Data source items have never been set, and is not currently loading.
	case uninitialized
	/// Data source items have never been set, and is currently loading for the first time.
	case refreshing
	/// Data source has results that have been set on it, and is not currently loading.
	case hasResults
	/// Data source has results that have been set on it, and is currently loading more.
	case loadingMore
	/// Data source has been set with an empty results collection, and is not currently loading.
	case empty
}

// MARK: - Protocols

public protocol PagedDataSourceDelegate: AnyObject {
	func loadNextPage(_ dataSource: AnyObject)
}

public class PagedDataSource<Cell: BaseCell, EmptyCell: BaseCell>: DataSource<Cell, EmptyCell> {
	
	// MARK: - Properties
	
	// Whether or not this data source may have more data to load.
	private var _hasMore = true
	
	// Date of the last call to beginLoading, kept to support applying the last refresh date in endLoading.
	private var _lastBeginLoadingDate: Date?
	
	// Date of the last call to the loadPageClosure. TODO: Set this somehow
	private var _lastLoadPageDate: Date?

	/// Whether or not this data source is currently loading data.
	private var _isLoading = false {
		didSet {
			delegate?.reloadData()
		}
	}
	
	/// Date of the most recent first page load.
	public private(set) var lastRefreshDate: Date?

	/// The current page, in index units (not page size offsets).
	public private(set) var currentPage: Int = 0
	public let pageSize: Int
	
	public weak var loadingDelegate: PagedDataSourceDelegate? = nil
	
	public var minRefreshInterval: TimeInterval = 60 * 5
	
	public var canRefresh: Bool {
		return !_isLoading
	}
	public var needsRefresh: Bool {
		return state == .uninitialized || (-(lastRefreshDate?.timeIntervalSinceNow ?? 0) > minRefreshInterval)
	}
	public var canLoadMore: Bool {
		return !_isLoading && _hasMore
	}
	
	/// Gets the current state of this paged data source.
	public var state: PagedDataSourceState {
		if needsSetItems {
			if _isLoading { return .refreshing }
			else { return .uninitialized }
		} else {
			if _isLoading { return .loadingMore }
			else if isEmpty { return .empty }
			else { return .hasResults }
		}
	}
	
	
	// MARK: - Inits
	
	public init(
		dequeueCellClosure: @escaping DequeueCellClosure = { tableView, section in
			return tableView.dequeueReusableCell(Cell.self)
		},
		emptyItem: EmptyCell.Item,
		pageSize: Int = 20,
		delegate: DataSourceDelegate? = nil) {
		self.pageSize = pageSize
		super.init(
			dequeueCellClosure: dequeueCellClosure,
			emptyItem: emptyItem,
			delegate: delegate)
	}
	
	
	// MARK: - Functions
	
	public override func reset() {
		super.reset()
		
		currentPage = 0
		_hasMore = true
	}
	
	public func appendPage(_ items: [Cell.Item]) {
		currentPage += 1
		
		// When an empty page comes back, mark that there are no more items to load.
		if items.count == 0 {
			_hasMore = false
		}
		
		let newItems = self.items + items
		
		setItems(newItems)
	}
	
	public func beginLoading(at date: Date? = nil) {
		_lastBeginLoadingDate = date
		_isLoading = true
	}
	
	public func endLoading(updateLastRefreshDate: Bool = false) {
		if updateLastRefreshDate {
			lastRefreshDate = _lastBeginLoadingDate
		}
		_isLoading = false
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// An additional cell shows for loading.
		if state == .loadingMore {
			return items.count + 1
		}
		
		return super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Return the loading cell.
		if state == .loadingMore && indexPath.row >= items.count {
			// TODO: Loading state
//			let cell = tableView.dequeueReusableCell(UNLoadingCell.self)
//			cell.beginAnimating()
//			return cell
		}
		
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
	
	public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let MinTimeBetweenPageLoads = 2.0
		if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height
			&& !_isLoading
			&& _hasMore
			&& currentPage > 0
			&& (_lastLoadPageDate == nil || -(_lastLoadPageDate?.timeIntervalSinceNow ?? 0) > MinTimeBetweenPageLoads) {
			loadingDelegate?.loadNextPage(self)
		}
	}
}
