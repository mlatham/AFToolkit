#import "AFPropertyInfo.h"


#pragma mark Class Interface

@interface NSObject (Runtime)


#pragma mark - Static Methods

// Gets the property info for a class.

+ (AFPropertyInfo *)propertyInfoForPropertyName: (NSString *)propertyName;


@end