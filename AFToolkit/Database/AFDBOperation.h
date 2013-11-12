#import "sqlite3.h"


#pragma mark Class Interface

@interface AFDBOperation : NSOperation


#pragma mark - Methods

- (id)initWithDatabase: (sqlite3 *)database
    lock: (NSRecursiveLock *)databaseLock
    task: (id (^)(sqlite3 *database, BOOL *success))task
    completion: (void (^)(id result, BOOL success))completion;
    
- (BOOL)isCompleted;


@end