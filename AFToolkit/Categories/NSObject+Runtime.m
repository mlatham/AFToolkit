#import "NSObject+Runtime.h"
#import <objc/runtime.h>


#pragma mark Constants

// Use the addresses as the key.
static char PROPERTY_INFO_KEY;


#pragma mark - Class Definition

@implementation NSObject (Runtime)


#pragma mark - Public Methods

// Gets the property info for the provided property name on this class. On
// first access, this method caches that property info in an associated
// object on this class.

+ (AFPropertyInfo *)propertyInfoForPropertyName: (NSString *)propertyName
{
	// Get the property info map for this type, or create it.
	NSMutableDictionary *propertyInfoMap = (NSMutableDictionary *)objc_getAssociatedObject(self, &PROPERTY_INFO_KEY);
	
	// Create the property info map.
	if (propertyInfoMap == nil)
	{
		propertyInfoMap = [[NSMutableDictionary alloc]
			init];
			
		objc_setAssociatedObject(self, &PROPERTY_INFO_KEY, propertyInfoMap, OBJC_ASSOCIATION_RETAIN);
	}
	
	// Check if the property info is cached.
	AFPropertyInfo *result = propertyInfoMap[propertyName];
	
	// If not, generate and cache the property info.
	if (result == nil)
	{
		unsigned int outCount;
		
		// Get this class's property metadata. This array needs to be freed.
		objc_property_t *properties = class_copyPropertyList(self, &outCount);
		
		// Find the property with the provided name.
		for (int i = 0; i < outCount; i++)
		{
			// Get the property.
			objc_property_t property = properties[i];
			
			// This is the property - get its attributes.
			const char *attributesCString = property_getAttributes(property);
			NSString *attributes = [NSString stringWithUTF8String: attributesCString];
			
			// Get the property name.
			const char *testPropertyNameCString = property_getName(property);
			NSString *testPropertyName = [NSString stringWithUTF8String: testPropertyNameCString];
			
			// Create the property info.
			AFPropertyInfo *propertyInfo = [[AFPropertyInfo alloc]
				init];
			
			// Set the property info name.
			propertyInfo.propertyName = testPropertyName;
			
			// Cache the property info.
			propertyInfoMap[propertyInfo.propertyName] = propertyInfo;
			
			// Set the result.
			if ([propertyName isEqualToString: testPropertyName])
			{
				result = propertyInfo;
			}
			
			NSArray *tokens = [attributes componentsSeparatedByString: @","];
			
			for (NSString *token in tokens)
			{
				if ([token length] > 0)
				{
					if ([token characterAtIndex: 0] ==  'T')
					{
						propertyInfo.propertyType = [token substringFromIndex: 1];
					}
					else if ([token characterAtIndex: 0] ==  'G')
					{
						propertyInfo.customGetterSelectorName = [token substringFromIndex: 1];
					}
					else if ([token characterAtIndex: 0] ==  'S')
					{
						propertyInfo.customSetterSelectorName = [token substringFromIndex: 1];
					}
					else if ([token characterAtIndex: 0] ==  'R')
					{
						propertyInfo.isReadonly = YES;
					}
					else if ([token characterAtIndex: 0] ==  'C')
					{
						propertyInfo.isCopy = YES;
					}
					else if ([token characterAtIndex: 0] ==  '&')
					{
						propertyInfo.isRetain = YES;
					}
					else if ([token characterAtIndex: 0] ==  'N')
					{
						propertyInfo.isNonatomic = YES;
					}
					else if ([token characterAtIndex: 0] ==  'D')
					{
						propertyInfo.isDynamic = YES;
					}
					else if ([token characterAtIndex: 0] ==  'W')
					{
						propertyInfo.isWeak = YES;
					}
				}
			}
		}
		
		// Free the properties.
		if (properties != NULL)
		{
			free(properties);
		}
	}
		
	// Return the property info, or nil if it didn't exist on this class.
	return result;
}


@end