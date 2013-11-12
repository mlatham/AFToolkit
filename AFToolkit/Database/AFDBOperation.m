#import "AFDBOperation.h"


#pragma mark Constants

static NSString * const FinishedKeyPath = @"isFinished";
static NSString * const ExecutingKeyPath = @"isExecuting";


#pragma mark - Class Definition

@implementation AFDBOperation
{
	@private UIBackgroundTaskIdentifier _exitBackgroundTask;
    @private NSRecursiveLock *_databaseLock;
    @private id (^_task)(sqlite3 *, BOOL *);
    @private void (^_completion)(id, BOOL);
    @private sqlite3 *_database;
	@private BOOL _executing;
	@private BOOL _finished;
	@private BOOL _completed;
}


#pragma mark - Constructors

- (id)initWithDatabase: (sqlite3 *)database
    lock: (NSRecursiveLock *)databaseLock
    task: (id (^)(sqlite3 *database, BOOL *success))task
    completion: (void (^)(id result, BOOL success))completion
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
    // Assert task is specified.
    AFAssert(AFIsNull(task) == NO);
    
	// Initialize instance variables.
    _database = database;
    _databaseLock = databaseLock;
    _task = [task copy];
    _completion = AFIsNull(completion) 
		? nil 
		: [completion copy];

	// Immediately begin a background task.
	[self AF_beginExitBackgroundTask];
	
	return self;
}


#pragma mark - Public Methods

- (BOOL)isCompleted
{
	@synchronized(self)
	{
		return _completed;
	}
}


#pragma mark - Overridden Methods

- (void)start
{
	// abort if cancelled
	if ([self isCancelled] == YES)
	{
		// raise finished notification
		[self willChangeValueForKey: FinishedKeyPath];		
		@synchronized(self)
		{
			_finished = YES;
		}		
		[self didChangeValueForKey: FinishedKeyPath];
		
		// callback delegate, if required
		if (AFIsNull(_completion) == NO)
		{
			[self performSelectorOnMainThread: @selector(AF_raiseCancelled) 
				withObject: nil 
				waitUntilDone: YES];
		}
		
		// stop processing
		return;
	}

	// start main execution on new thread
	[self willChangeValueForKey: ExecutingKeyPath];
	[NSThread detachNewThreadSelector: @selector(main) 
		toTarget: self
		withObject: nil];
		
	// raise executing notifcation
	@synchronized(self)
	{
		_executing = YES;
	}
	[self didChangeValueForKey: ExecutingKeyPath];
}

- (void)main
{
	// start connection
	@autoreleasepool
	{
		BOOL databaseLockAquired = NO;
		BOOL databaseRollbackRequired = NO;
		BOOL success = NO;
		id result = nil;
		@try 
		{           
			// acquire database lock
			[_databaseLock lock];
			databaseLockAquired = YES;
			
			// abort if cancelled
			if ([self isCancelled] == YES)
			{
				return;
			}
		
			// begin transaction
			if (sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, NULL) 
				== SQLITE_OK)
			{
				databaseRollbackRequired = YES;
			}
			
			// or throw
			else
			{
				[NSException raise: @"InvalidOperation" 
					format: @"Error beginning transaction: %s", 
					sqlite3_errmsg(_database)];
			}
			
			// abort if cancelled
			if ([self isCancelled] == YES)
			{
				return;
			}

			// perform task
			success = YES;
			result = _task(_database, &success);
					
			// abort if cancelled
			if ([self isCancelled] == YES)
			{
				return;
			}

			// commit transaction on success
			if (success == YES)
			{
				// mark rollback as not required
				databaseRollbackRequired = NO;
				
				// throw if commit fails
				if (sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, NULL) 
					!= SQLITE_OK)
				{
					[NSException raise: @"InvalidOperation" 
						format: @"Error committing transaction: %s", 
						sqlite3_errmsg(_database)];
				}
			}
			
			// release database lock
			[_databaseLock unlock];
			databaseLockAquired = NO;
		}
		
		// handle any exceptions
		@catch (NSException *e) 
		{
			// simply log exceptions
			AFLog(AFLogLevelError, @"async database execution exception: %@", [e reason]);
			
			// mark as failed
			success = NO;
		}
		
		// complete operation
		@finally
		{
			// rollback if required
			if (databaseRollbackRequired == YES)
			{
				// log error if rollback fails
				if (sqlite3_exec(_database, "ROLLBACK TRANSACTION", NULL, NULL, 
					NULL) != SQLITE_OK)
				{
					AFLog(AFLogLevelError, @"Error rolling back transaction: %s", 
						sqlite3_errmsg(_database));
				}
			}
			
			if (databaseLockAquired == YES)
			{
				[_databaseLock unlock];
			}

			// raise completed (if required)
			if ([self isCancelled] == NO 
				&& AFIsNull(_completion) == NO)
			{
				[self performSelectorOnMainThread: @selector(AF_raiseCompleted:) 
					withObject: [NSArray arrayWithObjects:
						result == nil ? [NSNull null] : result,
						[NSNumber numberWithBool: success], 
						nil]                    
					waitUntilDone: YES];		
			}
		
			// raise executing/finished notifcations
			[self willChangeValueForKey: FinishedKeyPath];
			[self willChangeValueForKey: ExecutingKeyPath];
			@synchronized(self)
			{
				_executing = NO;
				_finished = YES;
			}
			[self didChangeValueForKey: ExecutingKeyPath];
			[self didChangeValueForKey: FinishedKeyPath];
		}
	} // @autoreleasepool
}

- (BOOL)isConcurrent
{
	return YES;
}

- (BOOL)isExecuting
{
	@synchronized(self)
	{
		return _executing;
	}
}

- (BOOL)isFinished
{
	@synchronized(self)
	{
		return _finished;
	}
}


#pragma mark - Private Methods

- (void)AF_beginExitBackgroundTask
{
	UIApplication *application = [UIApplication sharedApplication];
	_exitBackgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^
	{
		[self AF_endExitBackgroundTask];
	}];
}

- (void)AF_endExitBackgroundTask
{
	UIApplication *application = [UIApplication sharedApplication];
	[application endBackgroundTask: _exitBackgroundTask];
    _exitBackgroundTask = UIBackgroundTaskInvalid;
}

- (void)AF_raiseCompleted: (NSArray *)data
{
	// Immediately begin a background task.
	[self AF_endExitBackgroundTask];

	// Raise completion.
    id result = [data objectAtIndex: 0];
    BOOL success = [[data objectAtIndex: 1]
        boolValue];
    _completion(AFIsNull(result)
		? nil
		: result, success);
}

- (void)AF_raiseCancelled
{
	// Immediately begin a background task.
	[self AF_endExitBackgroundTask];
	
	// Raise completion.
	_completion(nil, NO);
}


@end