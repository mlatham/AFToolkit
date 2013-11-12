#import "AFObjectModel.h"


#pragma mark Class Interface

@interface AFObjectProvider : NSObject


#pragma mark - Instance Methods

- (id)create: (Class)myClass
	withValues: (NSDictionary *)values;

- (id)create: (Class)myClass;

- (void)update: (id)object
	withValues: (NSDictionary *)values;


@end