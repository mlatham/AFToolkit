import UIKit

public class PagedSectionedDataSource<SectionView: BaseSectionView, Cell: BaseCell, EmptyCell: BaseCell>:
	SectionedDataSource<SectionView, Cell, EmptyCell>
	where SectionView.Item == Cell.Item {
	
	/// Closure type to group items. The result of this closure is a set of sections passed to the setSection function
	/// when appending a new page of items.
	public typealias GroupAndSortClosure = ([Cell.Item]) -> [SectionView.Section]
	
	
	// MARK: - Properties
	
	/// Unsorted, ungrouped items collection.
	private var _originalItems: [Cell.Item] = []
	
	/// Whether or not this data source may have more data to load.
	private var _hasMore = true
	
	/// Date of the last call to beginLoading, kept to support applying the last refresh date in endLoading.
	private var _lastBeginLoadingDate: Date?
	
	/// Date of the last call to the loadPageClosure.
	private var _lastLoadPageDate: Date?

	/// Whether or not this data source is currently loading data.
	private var _isLoading = false {
		didSet {
			delegate?.reloadData()
		}
	}
	
	/// Date of the most recent first page load.
	public private(set) var lastRefreshDate: Date?
	
	/// Closure callback to begin a new page load.
	public private(set) var loadPageClosure: VoidClosure
	
	/// Closure called when a new page of items is appended, to group cell items into sections, then sort and set them.
	public private(set) var groupAndSortClosure: GroupAndSortClosure
	
	/// The current page, in index units (not page size offsets).
	public private(set) var currentPage: Int = 0
	public let pageSize: Int
	public var title: String
	
	public var minRefreshInterval: TimeInterval = 60 * 5
	
	public var canRefresh: Bool {
		return !_isLoading
	}
	public var needsRefresh: Bool {
		return state == .uninitialized
			|| (-(lastRefreshDate?.timeIntervalSinceNow ?? 0) > minRefreshInterval)
	}
	public var canLoadMore: Bool {
		return !_isLoading && _hasMore
	}
	
	/// Gets the current state of this paged data source.
	public var state: PagedDataSourceState {
		if needsSetSections {
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
		groupAndSortClosure: @escaping GroupAndSortClosure,
		dequeueSectionViewClosure: @escaping DequeueSectionViewClosure = { tableView, section in
			return tableView.dequeueReusableSectionView(SectionView.self)
		},
		dequeueCellClosure: @escaping DequeueCellClosure = { tableView, section in
			return tableView.dequeueReusableCell(Cell.self)
		},
		loadPageClosure: @escaping VoidClosure,
		emptyItem: EmptyCell.Item,
		title: String,
		pageSize: Int = 20,
		delegate: DataSourceDelegate? = nil) {
		self.groupAndSortClosure = groupAndSortClosure
		self.loadPageClosure = loadPageClosure
		self.pageSize = pageSize
		self.title = title
		super.init(
			dequeueSectionViewClosure: dequeueSectionViewClosure,
			dequeueCellClosure: dequeueCellClosure,
			emptyItem: emptyItem,
			delegate: delegate)
	}
	
	
	// MARK: - Functions
	
	public override func reset() {
		super.reset()
		
		currentPage = 0
		_hasMore = true
		_originalItems = []
	}
	
	public func appendPage(_ items: [Cell.Item]) {
		currentPage += 1
		
		// When an empty page comes back, mark that there are no more items to load.
		if items.count == 0 {
			_hasMore = false
		}
		
		let newItems = _originalItems + items
		
		// Keep an array of the original items around, so we don't need to unpack the sections to perform these actions.
		_originalItems = newItems
		
		// Sort and group the cell items into sections.
		let sections = groupAndSortClosure(_originalItems)
		
		setSections(sections)
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
		if _showLoadingCell(for: section) {
			return sections[section].items.count + 1
		}
		
		return super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Return the loading cell.
		if _showLoadingCell(for: indexPath.section) && indexPath.row >= sections[indexPath.section].items.count {
			// TODO: Bring back the loading cell
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
			log(.debug, "Loading next page")
			_lastLoadPageDate = Date()
			loadPageClosure()
		}
	}
}


// MARK: - Helper Functions

private extension PagedSectionedDataSource {
	func _showLoadingCell(for section: Int) -> Bool {
		return !isEmpty && state == .loadingMore && section == sections.count - 1
	}
}

