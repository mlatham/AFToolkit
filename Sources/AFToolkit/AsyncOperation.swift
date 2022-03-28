import UIKit


/// An operation that is concurrent - its task runs asynchronously, not on the operation queue's thread.
class AsyncOperation: Operation {
	
	// MARK: - Properties
	
	static let NeverTimeout: TimeInterval = -1
	
	private var _backgroundTask = UIBackgroundTaskIdentifier.invalid
	
	private var _isCancelled = false
	private var _isExecuting = false
	private var _isFinished = false
	
	private let _timeoutError: String
	
	private let _createTime: Date
	private var _startTime: Date?
	private var _finishTime: Date?

	/// If an operation is not yet cancelled or finished, it's valid for calls to start(), finish() or cancel().
	/// Subclasses may use this property to determine whether or not to perform additional logic in finishWork() or
	/// cancelWork(), prior to calling the base implementation.
	var canStartFinishOrCancel: Bool {
		return !isCancelled && !isFinished
	}
	
	let timeout: TimeInterval
	
	/// Error when the async operation finishes.
	var error: NSError?
	
	/// Once an operation completes, returns the duration of time it took to execute.
	var executionDuration: TimeInterval? {
		guard let startTime = _startTime, let finishTime = _finishTime else {
			return nil
		}
		return finishTime.timeIntervalSince(startTime)
	}
	
	/// Returns the duration of time from creation to finish, or the duration of time from creation to now, if running.
	var totalDuration: TimeInterval? {
		guard let finishTime = _finishTime else {
			return Date().timeIntervalSince(_createTime)
		}
		return finishTime.timeIntervalSince(_createTime)
	}
	
	override var isAsynchronous: Bool {
		return true
	}
	
	override var isConcurrent: Bool {
		return false
	}
	
	// These properties are overridden to control their KVO notifications. See NOTE: in finish(). It may be
	// possible to get away from this technique, but it has worked well for years, so keep it unless you know
	// what you're doing.
	override var isExecuting: Bool {
		return _isExecuting
	}
	override var isFinished: Bool {
		return _isFinished
	}
	override var isCancelled: Bool {
		return _isCancelled
	}
	
	
	// MARK: - Inits
	
	/// Initializes an async operation that doesn't use a runloop, and has no timeout.
	override init() {
		_timeoutError = ""
		timeout = AsyncOperation.NeverTimeout
		_createTime = Date()
		
		super.init()
		
		_beginBackgroundTask()
	}
	
	/// Initializes an async operation that uses a runloop, and has a timeout.
	init(timeout: TimeInterval, timeoutError: String = "Operation timed out") {
		_timeoutError = timeoutError
		self.timeout = timeout
		_createTime = Date()
	
		super.init()
		
		_beginBackgroundTask()
	}
	
	
	// MARK: - Functions
	
	/// Never call super in start, because this is an asynchronous operation providing its own functionality there.
	override func start() {
		guard canStartFinishOrCancel else { return }
		
		willChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
		
		if self.debugLoggingEnabled {
			log(.debug, "\(self.description): Starting")
		}
		_isExecuting = true
		_startTime = Date()
		
		didChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
		
		// Queue up a timeout that cancels the operation from the main thread.
		if timeout > 0 {
			DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
				guard let strongSelf = self, strongSelf.canStartFinishOrCancel else { return }
				strongSelf.cancelWork(withError: NSError(self?._timeoutError ?? "", withCode: -1, log: false))
			}
		}
		
		// Kick off the work.
		beginWork()
	}
	
	override func cancel() {
		guard canStartFinishOrCancel else { return }
	
		super.cancel()
		
		willChangeValue(forKey: #keyPath(AsyncOperation.isCancelled))
		willChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
		willChangeValue(forKey: #keyPath(AsyncOperation.isFinished))
		
		if debugLoggingEnabled {
			var errorString: String = ""
			if let error = error {
				errorString = "\n\tERROR: \(error)"
			}
			log(error != nil ? .error : .debug, "\(self.description): Cancelled\(errorString)")
		}
		_isCancelled = true
		_isExecuting = false
		_isFinished = true
		_finishTime = Date()
		
		didChangeValue(forKey: #keyPath(AsyncOperation.isFinished))
		didChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
		didChangeValue(forKey: #keyPath(AsyncOperation.isCancelled))
		
		_endBackgroundTask()
	}
	
	func beginWork() {
		// Kick off work that happens on a background thread, then call finishWork.
		// This is a default implementation meant to be overridden - it just ends immediately.
		finish()
	}
	
	func finishWork(withError error: NSError?) {
		guard canStartFinishOrCancel else { return }
		self.error = error
		finish()
	}
	
	func cancelWork(withError error: NSError?) {
		guard canStartFinishOrCancel else { return }
		self.error = error
		cancel()
	}
	
	func finish() {
		guard canStartFinishOrCancel else { return }
	
		// Generates the KVO necessary for the queue to remove this operation. NOTE: This is necessary for the KVO to be
		// atomic - at no point will there be notifications for one property before the other is also set.
		willChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
		willChangeValue(forKey: #keyPath(AsyncOperation.isFinished))
		
		if debugLoggingEnabled {
			var errorString: String = ""
			if let error = error {
				errorString = "\n\tERROR: \(error)"
			}
			log(error != nil ? .error : .debug, "\(self.description): Finished\(errorString)")
		}
		_isExecuting = false
		_isFinished = true
		_finishTime = Date()
		
		didChangeValue(forKey: #keyPath(AsyncOperation.isFinished))
		didChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
		
		_endBackgroundTask()
	}
}


// MARK: - Helpers

private extension AsyncOperation {
	func _beginBackgroundTask() {
		guard _backgroundTask != UIBackgroundTaskIdentifier.invalid else {
			return
		}
		
		_backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
			self?._endBackgroundTask()
		}
	}
	
	func _endBackgroundTask() {
		if (_backgroundTask != UIBackgroundTaskIdentifier.invalid) {
			UIApplication.shared.endBackgroundTask(_backgroundTask)
		}
		_backgroundTask = UIBackgroundTaskIdentifier.invalid
	}
}
