import SQLite3
import Foundation
import UIKit

extension Sqlite {
	public class Client: NSObject {
	
		// MARK: - Constants
		
		static let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
		static let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
		
		public enum Errors: Error {
			case databaseConnectionClosed
			case connectionFailed(String)
			case execFailed(String)
		}
		
		
		// MARK: - Properties
		
		private let _preparedStatements = NSMutableDictionary()
		
		private var _databaseLock = NSRecursiveLock()
		private var _asyncQueryQueue = OperationQueue()
		private var _backgroundTask = UIBackgroundTaskIdentifier.invalid
		
		public private(set) var connected = false
		public private(set) var database: Database?
		public private(set) var databaseUrl: URL
		
		
		// MARK: - Inits
		
		public init(databaseUrl: URL) {
			self.databaseUrl = databaseUrl
			_asyncQueryQueue.maxConcurrentOperationCount = 1
			
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
		
		public func openConnection() {
			guard !connected else {
				return
			}
		
			// Create database connection.
			let databasePathNSString = databaseUrl.path as NSString
			if (sqlite3_open(databasePathNSString.utf8String, &database) != SQLITE_OK) {
				selfLog(.error, "Unable to connect to database '\(databaseUrl)': \(String(cString: sqlite3_errmsg(database)))")
			}
			
			// Enable foreign key support.
			if (sqlite3_exec(database, "PRAGMA foreign_keys = ON", nil, nil, nil) != SQLITE_OK) {
				selfLog(.error, "Unable to activate database foreign key support: \(String(cString: sqlite3_errmsg(database)))")
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
		
		public func closeConnection() {
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
		
		public func execute(statement: StatementClosure) throws {
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
		
		public func query(_ query: QueryClosure) throws -> Any? {
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
		public func beginExecute(
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
		public func beginQuery(
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
		
		public func resetOperationQueue() {
			_asyncQueryQueue.cancelAllOperations()
		}
		
		public func deleteDatabase() {
			closeConnection()
			
			// Delete the database file.
			do {
				try FileManager.default.removeItem(at: databaseUrl)
			} catch {
				selfLog(.error, "Failed to delete database at '\(databaseUrl)': \(error)")
			}
		}
		
		// Removes all prepared statements.
		@objc public func resetCache() {
			_ = try? self.execute { [weak self] (database, error) in
				let statementsCopy = self?._preparedStatements.copy() as? [OpaquePointer]
				
				self?._preparedStatements.removeAllObjects()
				statementsCopy?.forEach { sqlite3_finalize($0) }
			}
		}

		public func resetDatabase() {
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
		
		public func beginTransaction() throws {
			if (sqlite3_exec(database, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK) {
				throw Errors.execFailed("Error beginning transaction: \(String(cString: sqlite3_errmsg(database)))")
			}
		}
		
		public func commitTransaction() throws {
			if (sqlite3_exec(database, "COMMIT TRANSACTION", nil, nil, nil) != SQLITE_OK) {
				throw Errors.execFailed("Error committing transaction: \(String(cString: sqlite3_errmsg(database)))")
			}
		}
		
		public func rollbackTransaction() throws {
			if (sqlite3_exec(database, "ROLLBACK TRANSACTION", nil, nil, nil) != SQLITE_OK) {
				throw Errors.execFailed("Error committing transaction: \(String(cString: sqlite3_errmsg(database)))")
			}
		}
		
		public func query<T>(from table: Table<T>, _ query: String, cache: Bool) -> [T] {
			var results: [T]?
			
			do {
				results = try self.query { (_, error) in
					let startTime = CFAbsoluteTimeGetCurrent()
					defer {
						_logStats(for: query, startTime)
					}
					
					guard let statement = self.preparedStatement(query: query, cache: cache)
						else {
							selfLog(.debug, "Statement failed: \(query)")
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
				selfLog(.error, "Could not execute query: \(query). Error: \(error)")
			}
			
			return results ?? []
		}
		
		public func count(query: String, cache: Bool) -> Int {
			var result: Int?
			
			do {
				result = try self.query { (_, error) in
					let startTime = CFAbsoluteTimeGetCurrent()
					defer {
						_logStats(for: query, startTime)
					}
					
					guard let statement = self.preparedStatement(query: query, cache: cache)
						else {
							selfLog(.debug, "Statement failed: \(query)")
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
				selfLog(.error, "Could not execute count query: \(query). Error: \(error)")
			}
			
			return result ?? 0
		}
		
		@discardableResult
		public func beginQuery<T>(
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
						strongSelf.selfLog(.debug, "Statement failed: \(query)")
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
		
		public func preparedStatement(query: String, cache: Bool) -> Statement? {
			guard let database = database else {
				return nil
			}
		
			var statementPointer = _preparedStatements.object(forKey: query)
			
			if statementPointer == nil {
				statementPointer = _prepareStatement(query: query as NSString, database: database)
				
				// Only cache statements if needed.
				if cache {
					if selfLogEnabled {
						selfLog(.debug, "Caching statement:\n\t'\(query)")
					}
					_preparedStatements[query] = statementPointer
				}
			}
			
			return statementPointer as? Statement
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
				selfLog(.error, "Failed to compile statement:\n\t\(query)\n\tError:\(error)")
				// TODO: Throw.
				assert(false)
				return nil
			}
			
			return statement
		}
		
		private func _logStats(for query: String, _ startTime: CFAbsoluteTime) {
			guard selfLogEnabled else {
				return
			}
			
			let queryTime = CFAbsoluteTimeGetCurrent() - startTime
			selfLog(.debug, "Query took \(queryTime * 1000) ms")
			if queryTime > 0.2 {
				selfLog(.debug, "Slow query:\n\t \(query)")
			}
		}
	}
}
