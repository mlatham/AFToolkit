#import "AFDBClient.h"
#import "AFFileHelper.h"
#import "AFDBOperation.h"


#pragma mark Constants

static NSString * const AFDBExtension = @"sqlite";


#pragma mark - Class Definition

@implementation AFDBClient
{
	@private sqlite3 *_database;
	@private NSURL *_databaseURL;
	@private NSRecursiveLock *_databaseLock;
	@private NSOperationQueue *_asyncQueryQueue;
	@private UIBackgroundTaskIdentifier _exitBackgroundTask;
}


#pragma mark - Constructors

- (id)initWithDatabaseNamed: (NSString *)databaseName
{
    // Abort if base constructor fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}

	// Ensure database file is copied into documents folder.
	NSString *databaseFile = [NSString stringWithFormat: @"%@.%@", databaseName, AFDBExtension];
	_databaseURL = [AFFileHelper documentsURLByAppendingPath: databaseFile];
	
	// Initialize the database, if it doesn't already exist.
	if ([AFFileHelper documentsFileExists: databaseFile] == NO)
	{
		BOOL initialized = [AFDBClient initializeDatabaseNamed: databaseName 
			overwrite: NO];
		if (initialized == NO)
		{
			return nil;
		}
	}
	
	// Initialize instance variables.
    _databaseLock = [[NSRecursiveLock alloc]
        init];
    _asyncQueryQueue = [[NSOperationQueue alloc]
        init];
    [_asyncQueryQueue setMaxConcurrentOperationCount: 1];
    
    // Create database connection.
	if (sqlite3_open([[_databaseURL path] UTF8String], &_database) != SQLITE_OK)
	{
        AFLog(AFLogLevelError, @"Unable to connect to database '%@': %s", databaseName,
            sqlite3_errmsg(_database));
	}

    // Enable foreign key support.
    else if (sqlite3_exec(_database, "PRAGMA foreign_keys = ON", NULL, NULL, NULL) != SQLITE_OK)
    {
        AFLog(AFLogLevelError, @"Unable to activate database foreign key support: %s", 
            sqlite3_errmsg(_database));
    }
	
	// Register for notifications.
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(AF_applicationDidEnterBackground)
		name: UIApplicationDidEnterBackgroundNotification
		object: nil];

    // Return initialized instance.
	return self;
}


#pragma mark - Destructors

- (void)dealloc 
{
	// Unregister notifications.
	[[NSNotificationCenter defaultCenter]
		removeObserver: self 
		name: UIApplicationDidEnterBackgroundNotification 
		object: nil];

	// Reset (ensures any async operations are stopped).
	[self reset];
	
	// Close database connection.
	sqlite3_close(_database);
}


#pragma mark - Public Methods

+ (BOOL)initializeDatabaseNamed: (NSString *)databaseName
	overwrite: (BOOL) overwrite
{
	NSString *databaseFile = [NSString stringWithFormat: @"%@.%@", databaseName, AFDBExtension];

	// Determine database target URL.
	NSURL *databaseURL = [AFFileHelper documentsURLByAppendingPath: databaseFile];

	// Determine database source URL.
    NSURL *databaseBundleURL = [AFFileHelper mainBundleURLForFile: databaseFile];

	// Copy database from bundle, if not yet created.
	BOOL copied = [AFFileHelper copyFileFrom: databaseBundleURL
		to: databaseURL
		overwrite: overwrite];
		
	// Log if copy failed.
    if (copied == NO)
    {
        AFLog(AFLogLevelError, @"Failed to copy database to documents directory");
	}
	
	return copied;
}

- (id)execute: (SQLTaskDelegate)task
	success: (BOOL *)success
{
    // Start assuming success.
    *success = YES;

    // Acquire re-entrant lock.
    [_databaseLock lock];
    
    // Execute query.
    @try 
    {
        // Send query to delegate query.
        id result = task(_database, success);
        
        // Return result.
        return result;
    } 
    
    @catch (NSException *e)
    {
        // Fail.
        *success = NO;

        // Rethrow.
        @throw e;
    }
    
    @finally 
    {
        // Release lock.
        [_databaseLock unlock];
	}
}

- (DBExecutionToken)beginExecution: (SQLTaskDelegate)task
	completion: (SQLCompletedDelegate)completion
{
    // Create db operation.
    AFDBOperation *operation = [[AFDBOperation alloc]
        initWithDatabase: _database 
        lock: _databaseLock
        task: task 
        completion: completion];
    [operation setThreadPriority: 0.3];
        
    // Queue operation.
    [_asyncQueryQueue addOperation: operation];
    
    // Return operation as token.
    return operation;
}

- (BOOL)isExecutionCompleted: (DBExecutionToken)token
{
    NSArray *operations = [_asyncQueryQueue operations];
    NSUInteger operationIndex = [operations indexOfObjectIdenticalTo: token];
    return operationIndex != NSNotFound;
}

- (void)endExecution: (DBExecutionToken)token
{
    if ([self isExecutionCompleted: token] == NO)
    {
        NSOperation *operation = token;
        [operation waitUntilFinished];
    }
}

- (void)cancelExecution: (DBExecutionToken)token
{
    if ([self isExecutionCompleted: token] == NO)
    {
        NSOperation *operation = token;
        [operation cancel];
    }
}

- (void)reset
{
    [_asyncQueryQueue cancelAllOperations];
}


#pragma mark - Private Methods

- (void)AF_applicationDidEnterBackground
{
	// Begin the exit background task.
	[self AF_beginExitBackgroundTask];
	
	// Wait for all database operations to finish.
	[_asyncQueryQueue waitUntilAllOperationsAreFinished];
	
	// End the exit background task.
	[self AF_endExitBackgroundTask];
}

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


@end