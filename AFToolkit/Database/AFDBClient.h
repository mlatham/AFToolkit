#import "sqlite3.h"


#pragma mark Type Definitions

typedef id (^SQLTaskDelegate)(sqlite3 *database, BOOL *success);
typedef void (^SQLCompletedDelegate)(id result, BOOL success);
typedef id DBExecutionToken;


#pragma mark - Helper Functions
    
static inline void AFBindColumnString(sqlite3_stmt *statement, int column, NSString *string)
{
	if (AFIsNull(string) == YES)
	{
		sqlite3_bind_null(statement, column);
	}
	else
	{
		sqlite3_bind_text(statement, column, [string UTF8String], -1, SQLITE_TRANSIENT);
	}
}

static inline void AFBindColumnUrl(sqlite3_stmt *statement, int column, NSURL *url)
{
	if (AFIsNull(url) == YES)
	{
		sqlite3_bind_null(statement, column);
	}
	else
	{
		sqlite3_bind_text(statement, column, [[url absoluteString] 
			UTF8String], -1, SQLITE_TRANSIENT);
	}
}

static inline void AFBindColumnDate(sqlite3_stmt *statement, int column, NSDate *date)
{
	if (AFIsNull(date) == YES)
	{
		sqlite3_bind_null(statement, column);
	}
	else
	{
		NSTimeInterval timestamp = [date timeIntervalSince1970];
		sqlite3_bind_double(statement, column, timestamp);
	}
}

static inline NSString *AFColumnText(sqlite3_stmt *statement, int column)
{
	char *text = (char *)sqlite3_column_text(statement, column);
	if (text == NULL)
	{
		return nil;
	}
	else
	{
		return [NSString stringWithUTF8String: text];
	}
}

static inline NSURL *AFColumnUrl(sqlite3_stmt *statement, int column)
{
	char *text = (char *)sqlite3_column_text(statement, column);
	if (text == NULL)
	{
		return nil;
	}
	else
	{
		return [NSURL URLWithString: [NSString stringWithUTF8String: text]];
	}
}

static inline NSDate *AFColumnDate(sqlite3_stmt *statement, int column)
{
	if (sqlite3_column_type(statement, column) == SQLITE_NULL)
	{
		return nil;
	}
	else
	{
		NSTimeInterval timestamp = sqlite3_column_double(statement, column);
		return [NSDate dateWithTimeIntervalSince1970: timestamp];
	}
}

static inline BOOL AFColumnIsNullOrFalse(sqlite3_stmt *statement, int column)
{
	return sqlite3_column_type(statement, column) == SQLITE_NULL
		|| sqlite3_column_int(statement, column) == 0;
}

static inline void AFBeginTransaction(sqlite3 *database)
{
	// begin transaction
	if (sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL) 
		!= SQLITE_OK)
	{
		[NSException raise: @"InvalidOperation" 
			format: @"Error beginning transaction: %s", 
			sqlite3_errmsg(database)];
	}
}

static inline void AFCommitTransaction(sqlite3 *database)
{
	// begin transaction
	if (sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, NULL) 
		!= SQLITE_OK)
	{
		[NSException raise: @"InvalidOperation" 
			format: @"Error committing transaction: %s", 
			sqlite3_errmsg(database)];
	}
}

static inline void AFRollbackTransaction(sqlite3 *database)
{
	// begin transaction
	if (sqlite3_exec(database, "ROLLBACK TRANSACTION", NULL, NULL, NULL) 
		!= SQLITE_OK)
	{
		[NSException raise: @"InvalidOperation" 
			format: @"Error rolling back transaction: %s", 
			sqlite3_errmsg(database)];
	}
}


#pragma mark - Class Interface

@interface AFDBClient : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) NSURL *databaseURL;


#pragma mark - Methods

+ (BOOL)initializeDatabaseNamed: (NSString *)databaseName
	overwrite: (BOOL)overwrite;

- (id)initWithDatabaseNamed: (NSString *)databaseName;

- (id)execute: (SQLTaskDelegate)task
	success: (BOOL *)success;

- (DBExecutionToken)beginExecution: (SQLTaskDelegate)task
	completion: (SQLCompletedDelegate)completion;
- (BOOL)isExecutionCompleted: (DBExecutionToken)token;
- (void)endExecution: (DBExecutionToken)token;
- (void)cancelExecution: (DBExecutionToken)token;

- (void)reset;


@end