import SQLite3
import Foundation
import UIKit

extension Sqlite {
	class Client: NSObject {
	
		// MARK: - Constants
		
		static let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
		static let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
		static let SqliteExtension = "sqlite"
		
		enum Errors: Error {
			case databaseConnectionClosed
			case execFailed(String)
		}
		
		
		// MARK: - Properties
		
		private let _preparedStatements = NSMutableDictionary()

		private var _databaseUrl: URL
		private var _databaseName: String
		private var _databaseLock = NSRecursiveLock()
		private var _asyncQueryQueue = OperationQueue()
		private var _backgroundTask = UIBackgroundTaskIdentifier.invalid
		
		private(set) var connected = false
		private(set) var database: Database?
		
		
		// MARK: - Inits
		
		init?(databaseName: String) {
			// Ensure database file is copied into documents folder.
			let databaseFile = "\(databaseName).\(Client.SqliteExtension)"
			guard let databaseUrl = FileManager.urlByAppending(
				path: databaseFile,
				for: .documentDirectory) else {
				return nil
			}
			
			_databaseUrl = databaseUrl
			_databaseName = databaseName
			_asyncQueryQueue.maxConcurrentOperationCount = 1
			
			// Initialize the database, if it doesn't already exist.
			if (!FileManager.fileExists(filename: databaseFile, for: .documentDirectory)) {
				guard Client.initializeDatabase(name: databaseName, overwrite: false) else {
					return nil
				}
			}
			
			super.init()
			
			// Clear the prepared statement cache if the application receives a memory warning.
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(resetCache),
				name: UIApplication.didReceiveMemoryWarningNotification,
				object: nil)
			
			// Open the database connection.
			openConnection()
		}
		
		deinit {
			closeConnection()
		}
		
		
		// MARK: - Functions
		
		func openConnection() {
			guard !connected else {
				return
			}
		
			// Create database connection.
			let databasePathNSString = _databaseUrl.path as NSString
			if (sqlite3_open(databasePathNSString.utf8String, &database) != SQLITE_OK) {
				log(.error, "Unable to connect to database '\(_databaseName)': \(String(cString: sqlite3_errmsg(database)))")
			}
			
			// Enable foreign key support.
			if (sqlite3_exec(database, "PRAGMA foreign_keys = ON", nil, nil, nil) != SQLITE_OK) {
				log(.error, "Unable to activate database foreign key support: \(String(cString: sqlite3_errmsg(database)))")
			}
			
			// Register for notifications.
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(_applicationDidEnterBackground),
				name: UIApplication.didEnterBackgroundNotification,
				object: nil)
				
			// Track connection state.
			connected = true
		}
		
		func closeConnection() {
			guard connected else {
				return
			}
			
			// Unregister notifications.
			NotificationCenter.default.removeObserver(
				self,
				name: UIApplication.didEnterBackgroundNotification,
				object: nil)
			
			// Reset (ensures any async operations are stopped).
			resetOperationQueue()
			
			// Close database connection.
			sqlite3_close(database)
			
			// Track connection state.
			connected = false
		}
		
		func execute(statement: StatementClosure) throws {
			// Acquire re-entrant lock.
			_databaseLock.lock()
			
			defer {
				_databaseLock.unlock()
			}
			
			// Execute the query.
			var error: Error? = nil
			statement(database, &error)
			
			if let error = error {
				throw error
			}
		}
		
		func query(_ query: QueryClosure) throws -> Any? {
			// Acquire re-entrant lock.
			_databaseLock.lock()
			
			defer {
				_databaseLock.unlock()
			}
			
			// Execute the query.
			var error: Error? = nil
			let result = query(database, &error)
			
			if let error = error {
				throw error
			}
			
			return result
		}
		
		@discardableResult
		func beginExecute(
			statement: @escaping StatementClosure,
			completion: @escaping StatementCompletion) -> Operation {
			// Create operation.
			let operation = Operation(
				client: self,
				lock: _databaseLock,
				statement: statement,
				completion: completion)

			// Queue operation.
			_asyncQueryQueue.addOperation(operation)
			
			// Return a handle to the operation.
			return operation
		}
		
		@discardableResult
		func beginQuery(
			_ query: @escaping QueryClosure,
			completion: @escaping QueryCompletion) -> Operation {
			// Create operation.
			let operation = Operation(
				client: self,
				lock: _databaseLock,
				query: query,
				completion: completion)

			// Queue operation.
			_asyncQueryQueue.addOperation(operation)
			
			// Return a handle to the operation.
			return operation
		}
		
		func resetOperationQueue() {
			_asyncQueryQueue.cancelAllOperations()
		}
		
		func deleteDatabase() {
			closeConnection()
			
			// Delete the database file.
			do {
				try FileManager.default.removeItem(at: _databaseUrl)
			} catch {
				log(.error, "Failed to delete database at '\(_databaseUrl)': \(error)")
			}
		}
		
		// Removes all prepared statements.
		@objc func resetCache() {
			_ = try? self.execute { [weak self] (database, error) in
				let statementsCopy = self?._preparedStatements.copy() as? [OpaquePointer]
				
				self?._preparedStatements.removeAllObjects()
				statementsCopy?.forEach { sqlite3_finalize($0) }
			}
		}

		func resetDatabase() {
			resetCache()
		
			// Acquire re-entrant lock.
			_databaseLock.lock()

			defer {
				_databaseLock.unlock()
			}

			// Close the connection and delete database.
			deleteDatabase()
			
			// Re-open the connection.
			openConnection()
		}
		
		func beginTransaction() throws {
			if (sqlite3_exec(database, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK) {
				throw Errors.execFailed("Error beginning transaction: \(String(cString: sqlite3_errmsg(database)))")
			}
		}
		
		func commitTransaction() throws {
			if (sqlite3_exec(database, "COMMIT TRANSACTION", nil, nil, nil) != SQLITE_OK) {
				throw Errors.execFailed("Error committing transaction: \(String(cString: sqlite3_errmsg(database)))")
			}
		}
		
		func rollbackTransaction() throws {
			if (sqlite3_exec(database, "ROLLBACK TRANSACTION", nil, nil, nil) != SQLITE_OK) {
				throw Errors.execFailed("Error committing transaction: \(String(cString: sqlite3_errmsg(database)))")
			}
		}
		
		func query<T>(from table: Table<T>, _ query: String, cache: Bool) -> [T] {
			var results: [T]?
			
			do {
				results = try self.query { (_, error) in
					let startTime = CFAbsoluteTimeGetCurrent()
					defer {
						_logStats(for: query, startTime)
					}
					
					guard let statement = self.preparedStatement(query: query, cache: cache)
						else {
							log(.debug, "Statement failed: \(query)")
							return nil
					}
					var result = [T]()
					
					while sqlite3_step(statement) == SQLITE_ROW {
						if let row = table.readRow(statement) {
							result.append(row)
						}
					}
					
					if cache {
						// Reset the statement.
						sqlite3_reset(statement)
					} else {
						// Finalize the prepared statement if it's not being cached.
						sqlite3_finalize(statement)
					}
					
					return result
				} as? [T]
			} catch {
				log(.error, "Could not execute query: \(query). Error: \(error)")
			}
			
			return results ?? []
		}
		
		func count(query: String, cache: Bool) -> Int {
			var result: Int?
			
			do {
				result = try self.query { (_, error) in
					let startTime = CFAbsoluteTimeGetCurrent()
					defer {
						_logStats(for: query, startTime)
					}
					
					guard let statement = self.preparedStatement(query: query, cache: cache)
						else {
							log(.debug, "Statement failed: \(query)")
							return nil
					}
					var count: Int = 0
					
					// TODO: Should this be a single step?
					while sqlite3_step(statement) == SQLITE_ROW {
						count = Int(sqlite3_column_int(statement, 0))
					}
					
					if cache {
						// Reset the statement.
						sqlite3_reset(statement)
					} else {
						// Finalize the prepared statement if it's not being cached.
						sqlite3_finalize(statement)
					}
					
					return count
				} as? Int
			} catch {
				log(.error, "Could not execute count query: \(query). Error: \(error)")
			}
			
			return result ?? 0
		}
		
		@discardableResult
		func beginQuery<T>(
			from table: Table<T>,
			query: String,
			cache: Bool,
			completion: @escaping QueryCompletion) -> Operation? {
			
			return self.beginQuery({ [weak self] (_, error) -> Any? in
				guard let strongSelf = self else {
					return nil
				}
				
				let startTime = CFAbsoluteTimeGetCurrent()
				defer {
					strongSelf._logStats(for: query, startTime)
				}
				
				var result = [T]()
				guard let statement = strongSelf.preparedStatement(query: query, cache: cache)
					else {
						strongSelf.log(.debug, "Statement failed: \(query)")
						return nil
				}
				
				while sqlite3_step(statement) == SQLITE_ROW {
					if let row = table.readRow(statement) {
						result.append(row)
					}
				}
				
				if cache {
					// Reset the statement.
					sqlite3_reset(statement)
				} else {
					// Finalize the prepared statement if it's not being cached.
					sqlite3_finalize(statement)
				}
				
				return result
			}, completion: completion)
		}
		
		func preparedStatement(query: String, cache: Bool) -> Statement? {
			guard let database = database else {
				return nil
			}
		
			var statementPointer = _preparedStatements.object(forKey: query)
			
			if statementPointer == nil {
				statementPointer = _prepareStatement(query: query as NSString, database: database)
				
				// Only cache statements if needed.
				if cache {
					if debugLoggingEnabled {
						log(.debug, "Caching statement:\n\t'\(query)")
					}
					_preparedStatements[query] = statementPointer
				}
			}
			
			return statementPointer as? Statement
		}
		
		static func initializeDatabase(name: String, overwrite: Bool) -> Bool {
			let databaseFile = "\(name).\(SqliteExtension)"

			// Determine database target URL.
			guard let databaseURL = FileManager.urlByAppending(path: databaseFile, for: .documentDirectory) else {
				Logger.defaultLogger.log(.error, "Failed to get destination database URL \(databaseFile)")
				return false
			}

			// Determine database source URL.
			guard let databaseBundleURL = FileManager.mainBundleUrl(for: databaseFile) else {
				Logger.defaultLogger.log(.error, "Failed to find source database at \(databaseFile)")
				return false
			}

			// Copy database from bundle, if not yet created.
			let copied = FileManager.copyFile(atURL: databaseBundleURL, toURL: databaseURL, overwrite: overwrite)
				
			// Log if copy failed.
			if (!copied) {
				Logger.defaultLogger.log(.error, "Failed to copy database to documents directory")
			}
			
			return copied
		}
		
		
		// MARK: - Helpers
		
		@objc private func _applicationDidEnterBackground() {
			_beginBackgroundTask()
		
			_asyncQueryQueue.waitUntilAllOperationsAreFinished()
			
			_endBackgroundTask()
		}
		
		private func _beginBackgroundTask() {
			guard _backgroundTask != UIBackgroundTaskIdentifier.invalid else {
				return
			}
			
			_backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
				self?._endBackgroundTask()
			}
		}
		
		private func _endBackgroundTask() {
			if (_backgroundTask != UIBackgroundTaskIdentifier.invalid) {
				UIApplication.shared.endBackgroundTask(_backgroundTask)
			}
			_backgroundTask = UIBackgroundTaskIdentifier.invalid
		}
		
		private func _prepareStatement(
			query: NSString,
			database: Database) -> Statement? {
			var statement: Statement? = nil
			
			if sqlite3_prepare_v2(database, query.utf8String, -1, &statement, nil) != SQLITE_OK {
				let error = String(cString: sqlite3_errmsg(database))
				log(.error, "Failed to compile statement:\n\t\(query)\n\tError:\(error)")
				// TODO: Throw.
				assert(false)
				return nil
			}
			
			return statement
		}
		
		private func _logStats(for query: String, _ startTime: CFAbsoluteTime) {
			guard debugLoggingEnabled else {
				return
			}
			
			let queryTime = CFAbsoluteTimeGetCurrent() - startTime
			log(.debug, "Query took \(queryTime * 1000) ms")
			if queryTime > 0.2 {
				log(.debug, "Slow query:\n\t \(query)")
			}
		}
	}
}
