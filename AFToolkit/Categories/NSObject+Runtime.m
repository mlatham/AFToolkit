#import "NSObject+Runtime.h"
#import <objc/runtime.h>


#pragma mark Class Definition

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

- (void)setValue: (id)value
	forPropertyName: (NSString *)propertyName
	withTransformer: (NSValueTransformer *)transformer
{
	// Get the property info.
	AFPropertyInfo *propertyInfo = [self.class propertyInfoForPropertyName: propertyName];
	
	NSString *propertyClassName = nil;
	BOOL isPropertyCollection = NO;
	
	// The property type string is complicated, determine specifically if this property is
	// an NSMutableArray, NSMutableSet, NSMutableOrderedSet or AFMutableArray.
	if ([propertyInfo.propertyType characterAtIndex: 0] == '^')
	{
		// This is a pointer type property.
		propertyClassName = [propertyInfo.propertyType substringFromIndex: 1];
		
		// TODO: Move this to static creation.
		NSArray *collectionClasses = @[ @"NSMutableArray", @"NSMutableSet", @"NSMutableOrderedSet", @"AFMutableArray" ];
		
		// Determine if the property class is one of the collection types.
		if ([collectionClasses containsObject: propertyClassName])
		{
			// This is a collection type property.
			isPropertyCollection = YES;
		}
	}

	// Translate NSNulls to nil, or clear set in response to NSNull.
	if ([value isEqual: [NSNull null]])
	{
		// Clear collection for collection type properties.
		if (isPropertyCollection)
		{
			// Get the collection.
			id set = [self _mutableCollectionWithClassName: propertyClassName
				forKeyPath: propertyName];
				
			// Clear the collection.
			[set removeAllObjects];
		}
		// Clear value for non-collections.
		else
		{
			// Clear the value.
			[self setValue: nil
				forKeyPath: propertyName];
		}
	}
	
	// Value is not NSNull.
	else
	{
		// Replace items for collection type properties.
		if (isPropertyCollection)
		{
			// Get the collection.
			id set = [self _mutableCollectionWithClassName: propertyClassName
				forKeyPath: propertyName];
				
			// Clear the collection.
			[set removeAllObjects];
			
			// If the value is an array, apply the transform to each item.
			if ([value isKindOfClass: [NSArray class]])
			{
				// Tranform each item.
				for (id itemValue in value)
				{
					// Transform the value.
					id transformedItemValue = [self _transformValue: itemValue
						transformer: transformer];
					
					// Add the transformed item, if non-null.
					if (AFIsNull(transformedItemValue) == NO)
					{
						[set addObject: transformedItemValue];
					}
				}
			}
			else
			{
				// Skip non-array value.
				NSLog(@"WARNING: Non-array value being assigned to array property: %@. Class: %@",
					propertyName, NSStringFromClass(self.class));
			}
		}
		
		// Set value for non-collections.
		else
		{
			// Transform the value.
			id transformedValue = [self _transformValue: value
				transformer: transformer];
		
			// Set the transformed value.
			[self setValue: transformedValue
				forKey: propertyName];
		}
	}
}


#pragma mark - Private Methods

// Use the addresses as the key.
static char PROPERTY_INFO_MAP_KEY;

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

- (id)_transformValue: (id)value
	transformer: (NSValueTransformer *)transformer
{
	// Transform or use the original value.
	id transformedValue = AFIsNull(transformer) == NO
		? [transformer transformedValue: value]
		: value;
		
	// Don't allow NSNull.
	if ([transformedValue isEqual: [NSNull null]])
	{
		transformedValue = nil;
	}
	
	// Return value.
	return transformedValue;
}

- (id)_mutableCollectionWithClassName: (NSString *)className
	forKeyPath: (NSString *)keyPath
{
	// Get the appropriate collection class.
	if ([className isEqualToString: @"NSMutableArray"])
	{
		return [self mutableArrayValueForKeyPath: keyPath];
	}
	else if ([className isEqualToString: @"NSMutableSet"])
	{
		return [self mutableSetValueForKeyPath: keyPath];
	}
	else if ([className isEqualToString: @"NSMutableOrderedSet"])
	{
		return [self mutableOrderedSetValueForKeyPath: keyPath];
	}
	else if ([className isEqualToString: @"AFMutableArray"])
	{
		return [self valueForKeyPath: keyPath];
	}
	
	// Class name didn't match any core collection.
	return nil;
}


@end