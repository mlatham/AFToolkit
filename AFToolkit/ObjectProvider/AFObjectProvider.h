#import "AFObjectModel.h"


#pragma mark Class Interface

@interface AFObjectProvider : NSObject


#pragma mark - Instance Methods

// Parse all root and collection keys in the provided values.
- (NSDictionary *)parse: (NSDictionary *)values;

- (id)create: (Class)myClass;

- (id)create: (Class)myClass
	values: (NSDictionary *)values;

- (id)fetch: (Class)myClass
	values: (NSDictionary *)values;

// Helper method only valid for models with one ID keypath.
- (id)fetchOrCreate: (Class)myClass
	idValue: (NSString *)idValue;

- (id)updateOrCreate: (Class)myClass
	values: (NSDictionary *)values;

- (void)update: (id)object
	values: (NSDictionary *)values;


@end