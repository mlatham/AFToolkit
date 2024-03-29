import SQLite3
import UIKit

extension Sqlite {
	public class Operation: AsyncOperation {

		// MARK: - Enums
		
		public enum Errors: Error {
			case databaseUnavailable
			case cancelled
			case unknown
		}


		// MARK: - Properties

		private var _client: Client
		private let _databaseLock: NSRecursiveLock
		
		private var _queryClosure: QueryClosure?
		private var _queryCompletion: QueryCompletion?
		
		private var _statementClosure: StatementClosure?
		private var _statementCompletion: StatementCompletion?


		// MARK: - Inits
		
		public init(
			client: Client,
			lock: NSRecursiveLock,
			query: @escaping QueryClosure,
			completion: @escaping QueryCompletion) {
			
			_client = client
			_databaseLock = lock
			_queryClosure = query
			_queryCompletion = completion
			
			super.init()
		}
		
		public init(
			client: Client,
			lock: NSRecursiveLock,
			statement: @escaping StatementClosure,
			completion: @escaping StatementCompletion) {
			
			_client = client
			_databaseLock = lock
			_statementClosure = statement
			_statementCompletion = completion
			
			super.init()
		}
		
		
		// MARK: - Functions
		
		public override func beginWork() {
			var databaseLockAcquired = false
			
			var result: Any? = nil
			var resultError: Error? = Errors.cancelled
			
			guard let database = _client.database else {
				finishWork(withError: Errors.databaseUnavailable)
				return
			}
			
			defer {
				if (databaseLockAcquired) {
					_databaseLock.unlock()
				}

				// Raise completed and finish work.
				if (!self.isCancelled) {
					// Call back with the results on the main thread.
					DispatchQueue.main.sync {
						if let completion = _queryCompletion {
							completion(result, resultError)
						} else if let completion = _statementCompletion {
							completion(resultError)
						}
					}
					
					finishWork(withError: resultError)
				}
			}

			_databaseLock.lock()
			databaseLockAcquired = true
			
			// Abort if cancelled.
			if (self.isCancelled) {
				return
			}
			
			// Perform task.
			resultError = nil
			if let query = _queryClosure {
				result = query(database, &resultError)
			} else if let statement = _statementClosure {
				do {
					try statement(database, &resultError)
				} catch let e {
					resultError = e
				}
			}
			
			// Abort if cancelled.
			if (self.isCancelled) {
				return
			}
			
			// Release database lock.
			_databaseLock.unlock()
			databaseLockAcquired = false
		}
	}
}
