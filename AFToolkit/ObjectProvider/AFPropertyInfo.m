#import "AFPropertyInfo.h"


#pragma mark Class Definition

@implementation AFPropertyInfo
{
	@private __strong Class _propertyClass;
	@private __strong NSString *_propertyClassName;
}


#pragma mark - Properties

- (void)setPropertyType: (NSString *)propertyType
{
	_propertyType = propertyType;
	
	// If this property is a pointer type, set the property class and class name (if available).
	if ([_propertyType characterAtIndex: 0] == '^')
	{
		// Resolve the type name from the property type string.
		NSString *typeName = [_propertyType substringFromIndex: 1];
	
		// Resolve and set the property class. NSClassFromString returns nil if typeName is not a class name.
		_propertyClass = NSClassFromString(typeName);
	
		// Only set the property class name if the class existed.
		if (_propertyClass != nil)
		{
			_propertyClassName = typeName;
		}
	}
}


@end // @implementation AFPropertyInfo