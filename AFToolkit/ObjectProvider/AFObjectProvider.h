#import "AFObjectModel.h"


#pragma mark Class Interface

@interface AFObjectProvider : NSObject


#pragma mark - Static Methods

+ (void)registerObjectModel: (AFObjectModel *)objectModel;

+ (AFObjectModel *)objectModelForClass: (Class)myClass;


#pragma mark - Instance Methods

- (id)createInstanceOf: (Class)myClass
	withValues: (NSDictionary *)values;

- (id)createInstanceOf: (Class)myClass;

- (void)updateObject: (id)object
	withValues: (NSDictionary *)values;


@end // @interface AFObjectProvider