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


#pragma mark AFObjectModel Protocol

@protocol AFObjectModel<NSObject>

@required

- (AFObjectModel *)objectModel;

@optional

+ (void)update: (id)value
	values: (NSDictionary *)values
	provider: (id)provider;

@end