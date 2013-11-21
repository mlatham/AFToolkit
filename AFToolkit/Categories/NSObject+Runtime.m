#import "NSObject+Runtime.h"
#import <objc/runtime.h>


#pragma mark Constants

// Use the addresses as the key.
static char TEMPLATE_KEY;
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
				if ([token isEqualToString: @"T"])
				{
					propertyInfo.propertyType = token;
				}
				else if ([token isEqualToString: @"G"])
				{
					propertyInfo.customGetterSelectorName = token;
				}
				else if ([token isEqualToString: @"S"])
				{
					propertyInfo.customSetterSelectorName = token;
				}
				else if ([token isEqualToString: @"R"])
				{
					propertyInfo.isReadonly = YES;
				}
				else if ([token isEqualToString: @"C"])
				{
					propertyInfo.isCopy = YES;
				}
				else if ([token isEqualToString: @"&"])
				{
					propertyInfo.isRetain = YES;
				}
				else if ([token isEqualToString: @"N"])
				{
					propertyInfo.isNonatomic = YES;
				}
				else if ([token isEqualToString: @"D"])
				{
					propertyInfo.isDynamic = YES;
				}
				else if ([token isEqualToString: @"W"])
				{
					propertyInfo.isWeak = YES;
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

+ (instancetype)template
{
	id instance = (id)objc_getAssociatedObject(self, &TEMPLATE_KEY);
	
	// Create the template on demand.
	if (instance == nil)
	{
		instance = [self alloc];
	
		objc_setAssociatedObject(self, &TEMPLATE_KEY, instance, OBJC_ASSOCIATION_RETAIN);
	}
	
	return instance;
}


@end