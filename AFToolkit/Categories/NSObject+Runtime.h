#import "AFPropertyInfo.h"


#pragma mark Class Interface

@interface NSObject (Runtime)


#pragma mark - Static Methods

// Gets the property info for a class.

+ (AFPropertyInfo *)propertyInfoForPropertyName: (NSString *)propertyName;

// Gets a singleton allocated (but uninitialized) instance of this type of object.

+ (instancetype)template;


@end