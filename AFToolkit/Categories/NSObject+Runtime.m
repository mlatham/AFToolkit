#import "NSObject+Runtime.h"
#import <objc/runtime.h>


#pragma mark Constants

// Use the addresses as the key.
static char PROPERTY_INFO_MAP_KEY;
static char TEMPLATE_KEY;


#pragma mark - Class Definition

@implementation NSObject (Runtime)


#pragma mark - Public Methods

+ (AFPropertyInfo *)propertyInfoForPropertyName: (NSString *)propertyName
{
	// Get or create the property info map.
	NSMutableDictionary *propertyInfoMap = self.propertyInfoMap;
	
	// Check if the property info is cached.
	AFPropertyInfo *result = propertyInfoMap[propertyName];
	
	// If not, generate and cache the property info.
	if (result == nil)
	{
		const char *propertyNameCString = [propertyName UTF8String];

		unsigned int outCount;
		
		// Get this class's property metadata. TODO: Cache this per-class?
		objc_property_t *properties = class_copyPropertyList(self, &outCount);
		
		// Find the property with the provided name.
		for (int i = 0; i < outCount; i++)
		{
			// Get the property.
			objc_property_t property = properties[i];
			
			// Get the property name.
			const char *testPropertyNameCString = property_getName(property);
			
			// This is the property - get its attributes.
			const char *attributes = property_getAttributes(property);
			
			// Copy the attributes into a mutable representation.
			char *mutableAttributes = (char *)malloc(strlen(attributes) * sizeof(char));
			strcpy(mutableAttributes, attributes);
			
			// Create the property info.
			AFPropertyInfo *propertyInfo = [[AFPropertyInfo alloc]
				init];
			propertyInfo.propertyName = propertyName;
			
			// Attributes are comma-separated.
			char *token = strtok(mutableAttributes, ",");
			
			// Tokenize the string.
			while (token != NULL)
			{
				char marker = token[0];
			
				switch (marker)
				{
					case 'T':
					{
						// Advance past the type marker.
						token++;
						
						propertyInfo.propertyType = [NSString stringWithUTF8String: token];
						
						break;
					}
					case 'G':
					{
						// Advance past the type marker.
						token++;
						
						propertyInfo.customGetterSelectorName = [NSString stringWithUTF8String: token];
						
						break;
					}
					case 'S':
					{
						// Advance past the type marker.
						token++;
						
						propertyInfo.customSetterSelectorName = [NSString stringWithUTF8String: token];
						
						break;
					}
					case 'R':
					{
						propertyInfo.isReadonly = YES;
						
						break;
					}
					case 'C':
					{
						propertyInfo.isCopy = YES;
					
						break;
					}
					case '&':
					{
						propertyInfo.isRetain = YES;
					
						break;
					}
					case 'N':
					{
						propertyInfo.isNonatomic = YES;
					
						break;
					}
					case 'D':
					{
						propertyInfo.isDynamic = YES;
					
						break;
					}
					case 'W':
					{
						propertyInfo.isWeak = YES;
					
						break;
					}
				}
				
				// Get the next token.
				token = strtok(NULL, mutableAttributes);
				
				// Set the result.
				if (strcmp(propertyNameCString, testPropertyNameCString) == 0)
				{
					result = propertyInfo;
				}
				
				// Cache the property info.
				propertyInfoMap[propertyName] = propertyInfo;
			}
		}
	}
		
	// Return the property info, or nil if it didn't exist on this class.
	return result;
}

+ (instancetype)template
{
	id instance = (id)objc_getAssociatedObject(self, &TEMPLATE_KEY);
	
	// Create the property info map on demand.
	if (instance == nil)
	{
		instance = [self alloc];
	
		objc_setAssociatedObject(self, &TEMPLATE_KEY, instance, OBJC_ASSOCIATION_RETAIN);
	}
	
	return instance;
}


#pragma mark - Private Methods

+ (NSMutableDictionary *)propertyInfoMap
{
	NSMutableDictionary *propertyInfoMap = (NSMutableDictionary *)objc_getAssociatedObject(self, &PROPERTY_INFO_MAP_KEY);
	
	// Create the property info map on demand.
	if (propertyInfoMap == nil)
	{
		self.propertyInfoMap = [NSMutableDictionary dictionary];
		
		return self.propertyInfoMap;
	}
	
	return propertyInfoMap;
}

+ (void)setPropertyInfoMap: (NSMutableDictionary *)propertyInfoMap
{
	objc_setAssociatedObject(self, &PROPERTY_INFO_MAP_KEY, propertyInfoMap, OBJC_ASSOCIATION_RETAIN);
}


@end