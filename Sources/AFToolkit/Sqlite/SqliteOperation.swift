import SQLite3
import UIKit

class SqliteOperation: AsyncOperation {

	// MARK: - Enums
	
	enum Errors: Error {
		case beginTransactionFailed
		case commitTransactionFailed
		case unknown
	}


	// MARK: - Properties

	private var _database: sqlite3?
	private let _databaseLock: NSRecursiveLock
	private var _task: SqliteTask
	private var _completion: SqliteCompletion


    // MARK: - Inits
    
	init(
		database: sqlite3?,
		lock: NSRecursiveLock,
		task: SqliteTask,
		completion: SqliteCompletion) {
		
		_database = database
		_databaseLock = lock
		_task = task
		_completion = completion
		
		super.init()
	}
	
	
	// MARK: - Functions
	
	override func beginWork() {
		var databaseLockAcquired = false
		var databaseRollbackRequired = false
		var success = false
		var result: AnyObject = nil
		
		defer {
			// Rollback if required.
			if (databaseRollbackRequired) {
				// Log error if rollback fails.
				if (sqlite3_exec(_database, "ROLLBACK TRANSACTION", nil, nil, nil) != SQLITE_OK) {
					log(.error, "Error rolling back transaction: \(String.fromCString(sqlite3_errmsg(_database)))";
				}
			}
			
			if (databaseLockAquired) {
				_databaseLock.unlock()
			}

			// Raise completed and finish work.
			if (!self.isCancelled) {
				// Call back with the results.
				DispatchQueue.main.sync {
					_completion(result, success)
				}
				
				finishWork(withError: nil)
			}
		}
		
		do {
			_databaseLock.lock()
			databaseLockAcquired = true
			
			// Abort if cancelled.
			if (self.isCancelled) {
				return
			}
			
			// Begin transaction.
			if (sqlite3_exec(_database, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK) {
				databaseRollbackRequired = true
			} else {
				log(.error, "Error beginning transaction: \(String.fromCString(sqlite3_errmsg(_database)))";
				throw Errors.beginTransactionFailed
			}
			
			// Abort if cancelled.
			if (self.isCancelled) {
				return
			}
			
			// Perform task.
			success = true
			result = _task(_database, &success)
			
			// Abort if cancelled.
			if (self.isCancelled) {
				return
			}
			
			// Commit transaction on success.
			if (success) {
				databaseRollbackRequired = false
				
				// Throw if commit fails.
				if (sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, NULL) != SQLITE_OK) {
					throw Errors.commitTransactionFailed
				}
			}
			
			// Release database lock.
			_databaseLock.unlock()
			databaseLockAcquired = false
		} catch {
			log(.error, "Database error: \(error)")
			
			// Mark as failed.
			success = false
		}
	}
}
