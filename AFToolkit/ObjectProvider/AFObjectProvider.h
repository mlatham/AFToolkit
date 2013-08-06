#import "AFObjectModel.h"


#pragma mark Class Interface

@interface AFObjectProvider : NSObject


#pragma mark - Static Methods

+ (void)registerObjectModel: (AFObjectModel *)objectModel;


#pragma mark - Instance Methods

- (id)createInstanceOf: (Class)instanceClass
	withValues: (NSDictionary *)values;

- (void)updateObject: (id)object
	withValues: (NSDictionary *)values;


@end // @interface AFObjectProvider