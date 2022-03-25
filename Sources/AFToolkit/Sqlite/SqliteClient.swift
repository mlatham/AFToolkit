import SQLite3


class SqliteClient {
	
	// MARK: - Constants
	
	private let SqliteExtension = "sqlite"
	
	
	// MARK: - Properties

	private var _database: sqlite3?
	private var _databaseUrl: URL?
	private var _databaseLock = NSRecursiveLock()
	private var _asyncQueryQueue = OperationQueue()
	private var _backgroundTask = UIBackgroundTaskIdentifier.invalid
	
	
	// MARK: - Inits
	
	init?(databaseName: String) {
		// Ensure database file is copied into documents folder.
		let databaseFile = "\(databaseName).\(SqliteExtension)"
		_databaseUrl = FileManager.urlByAppending(
			path: databaseFile,
			for: .documentDirectory)
		
		// Initialize the database, if it doesn't already exist.
		if (!FileManager.fileExists(filename: databaseFile, for: .documentDirectory)) {
			guard SqliteClient.initializeDatabase(name: databaseName, overwrite: false) else {
				return nil
			}
		}
		
		_asyncQueryQueue.maxConcurrentOperationCount = 1
		
		// Create database connection.
		if (sqlite3_open(_databaseURL.path?.utf8, &_database) != SQLITE_OK) {
			log(.error, "Unable to connect to database '\(databaseName)': \(String.fromCString(sqlite3_errmsg(_database)))")
		
		// Enable foreign key support.
		} else if (sqlite3_exec(_database, "PRAGMA foreign_keys = ON", nil, nil, nil) != SQLITE_OK) {
			log(.error, "Unable to activate database foreign key support: \(String.fromCString(sqlite3_errmsg(_database)))")
		}
		
		// Register for notifications.
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(_applicationDidEnterBackground),
			name: UIApplication.didEnterBackgroundNotification,
			object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(
			self,
			name: UIApplication.didEnterBackgroundNotification,
			object: nil)
		
		// Reset (ensures any async operations are stopped).
		reset()
		
		// Close database connection.
		sqlite3_close(_database)
	}
	
	func execute(task: SqliteTask, success: Bool?) -> AnyObject {
		// Start assuming success.
		success = true
		
		// Acquire re-entrant lock.
		_databaseLock.lock()
		
		defer {
			_databaseLock.unlock()
		}
		
		do {
			// Execute the query.
			let result = task(_database, success)
			return result
		} catch {
			// Fail.
			success = false

			// Rethrow.
			throw error
		}
	}
	
	func beginExecution(task: SqliteTask, completion: SqliteCompletion) -> SqliteOperation {
		// Create operation.
		let operation = SqliteOperation(
			database: _database,
			lock: _databaseLock,
			task: task,
			completion: completion)

		// Queue operation.
		_asyncQueryQueue.addOperation(operation)
		
		// Return a handle to the operation.
		return operation
	}
	
	func reset() {
		_asyncQueryQueue.cancelAllOperations()
	}
	
	func _applicationDidEnterBackground() {
		_beginExitBackgroundTask()
	
		_asyncQueryQueue.waitUntilAllOperationsAreFinished()
		
		_endExitBackgroundTask()
	}
	
	static func initializeDatabase(name: String, overwrite: Bool): Bool {
		let databaseFile = "\(databaseName).\(SqliteExtension)"

		// Determine database target URL.
		let databaseURL = FileManager.urlByAppending(path: databaseFile, for: .documentsDirectory)

		// Determine database source URL.
		NSURL *databaseBundleURL = FileManager.mainBundleURL(for: databaseFile)

		// Copy database from bundle, if not yet created.
		let copied = FileHelper.copyFile(atURL: databaseBundleURL, toURL: databaseURL, overwrite: overwrite)
			
		// Log if copy failed.
		if (!copied) {
			log(.error, "Failed to copy database to documents directory")
		}
		
		return copied
	}
}


// MARK: - Helpers

private extension SqliteClient {
	func _beginBackgroundTask() {
		guard _backgroundTask != UIBackgroundTaskIdentifier.invalid else {
			return
		}
		
		_backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self]
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

//static inline void AFBeginTransaction(sqlite3 *database)
//{
//	// begin transaction
//	if (sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL)
//		!= SQLITE_OK)
//	{
//		[NSException raise: @"InvalidOperation"
//			format: @"Error beginning transaction: %s",
//			sqlite3_errmsg(database)];
//	}
//}
//
//static inline void AFCommitTransaction(sqlite3 *database)
//{
//	// begin transaction
//	if (sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, NULL)
//		!= SQLITE_OK)
//	{
//		[NSException raise: @"InvalidOperation"
//			format: @"Error committing transaction: %s",
//			sqlite3_errmsg(database)];
//	}
//}
//
//static inline void AFRollbackTransaction(sqlite3 *database)
//{
//	// begin transaction
//	if (sqlite3_exec(database, "ROLLBACK TRANSACTION", NULL, NULL, NULL)
//		!= SQLITE_OK)
//	{
//		[NSException raise: @"InvalidOperation"
//			format: @"Error rolling back transaction: %s",
//			sqlite3_errmsg(database)];
//	}
//}
