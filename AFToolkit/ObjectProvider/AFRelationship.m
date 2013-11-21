#import "AFRelationship.h"
#import "AFPropertyInfo.h"
#import <objc/runtime.h>


#pragma mark Class Definition

@implementation AFRelationship
{
	@private __strong NSMutableDictionary *_propertyInfoMap;
	@private __strong Class _hasManyClass;
}


#pragma mark - Constructors

- (id)initWithKeys:(NSArray *)keys
	type: (AFRelationshipType)type
	hasManyClass: (Class)hasManyClass
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_keys = keys;
	_type = type;
	_hasManyClass = hasManyClass;
	_propertyInfoMap = [NSMutableDictionary dictionary];
	
	// Return initialized instance.
	return self;
}

- (id)initWithKeys: (NSArray *)keys
{
	return [self initWithKeys: keys
		type: AFRelationshipTypeHasOne
		hasManyClass: nil];
}

- (id)initWithHasMany: (Class)hasManyClass
	keys: (NSArray *)keys
{
	return [self initWithKeys: keys
		type: AFRelationshipTypeHasMany
		hasManyClass: hasManyClass];
}


#pragma mark - Dealloc

- (void)dealloc
{
#if defined(DEBUG_OBJECT_PROVIDER)
	AFLog(AFLogLevelDebug, @"AFRelationship::dealloc");
#endif
}


#pragma mark - Public Methods

+ (instancetype)key: (NSString *)key
{
	return [[self alloc]
		initWithKeys: @[ key ]];
}

+ (instancetype)keys: (NSArray *)keys
{
	return [[self alloc]
		initWithKeys: keys];
}

+ (instancetype)hasMany: (Class)hasManyClass
	keys: (NSArray *)keys
{
	return [[self alloc]
		initWithHasMany: hasManyClass
		keys: keys];
}

+ (instancetype)hasMany: (Class)hasManyClass
	key: (NSString *)key
{
	return [[self alloc]
		initWithHasMany: hasManyClass
		keys: @[ key ]];
}

- (void)update: (id)object
	values: (NSDictionary *)values
	propertyName: (NSString *)propertyName
	provider: (AFObjectProvider *)provider
{
	id value = nil;

	// First - resolve the available value key.
	for (NSString *key in _keys)
	{
		// If the key is composite, descent into values.
		NSArray *subKeys = [key componentsSeparatedByString: @"."];
	
		// Descent into the values for subkeys.
		NSDictionary *subValues = values;
		
		// Traverse each subkey.
		for (int i = 0; i < [subKeys count]; i++)
		{
			if (AFIsNull(subValues) == NO)
			{
				// Get the subkey.
				NSString *subKey = subKeys[i];
				
				if (i < [subKeys count] - 1)
				{
					// Descent into the subvalues with each subkey.
					subValues = subValues[subKey];
				}
				else
				{
					// Update the value with the last subkey.
					value = subValues[key];
				}
			}
		}
		
		// Stop searching as soon as a value is found.
		if (value != nil)
		{
			break;
		}
	}
	
	// Set the value.
	if (value != nil)
	{
		switch (_type)
		{
			case AFRelationshipTypeHasMany:
			{
				[self _setHasManyValue: value
					target: object
					propertyName: propertyName
					provider: provider];
			
				break;
			}
			case AFRelationshipTypeHasOne:
			{
				[self _setHasOneValue: value
					target: object
					propertyName: propertyName
					provider: provider];
			
				break;
			}
		}
	}
}

- (id)transformValue: (id)value
	toClass: (Class)toClass
	provider: (AFObjectProvider *)provider
{
	// Normalize all nils or NSNulls to a nil result.
	id result = nil;

	// Attempt to parse the value, if set.
	if (AFIsNull(value) == NO)
	{
		AFObjectModel *objectModel = [AFObjectModel objectModelForClass: toClass];
	
		// If there is an object model, parse into an instance of that model.
		if (objectModel != nil)
		{
			// Ensure the value is an NSDictionary.
			if ([value isKindOfClass: NSDictionary.class])
			{
				// Parse the value as an entity.
				result = [provider updateOrCreate: toClass
					values: value];
			}
			else if ([value isKindOfClass: NSString.class])
			{
				// Interpret the value as an ID.
				result = [provider fetchOrCreate: toClass
					idValue: value];
			}
			else if ([value respondsToSelector: @selector(stringValue)])
			{
				// Interpret the value as an ID.
				result = [provider fetchOrCreate: toClass
					idValue: [value stringValue]];
			}
			else
			{
				// Ignore any non-dictionary, non-ID values. TODO: Fail in debug.
			}
		}
		// Otherwise, try to assign the non-entity value directly.
		else
		{
			// TODO: Provide type conversion?
			result = value;
		}
	}
	
	// Return the value.
	return result;
}


#pragma mark - Private Methods

// Gets the property info for the provided property name on this class. On
// first access, this method caches that property info in an associated
// object on this class.

- (AFPropertyInfo *)_propertyInfoForClass: (Class)myClass
	propertyName: (NSString *)propertyName
{
	@synchronized(self)
	{
		// Get or create the property info map.
		NSMutableDictionary *propertyInfoMap = _propertyInfoMap;
		
		// Check if the property info is cached.
		AFPropertyInfo *result = propertyInfoMap[propertyName];
		
		// If not, generate and cache the property info.
		if (result == nil)
		{
			unsigned int outCount;
			
			// Get the desired property name, as a c-string. This c-string is a pointer to the
			// contents of the propertyName string. It does not need to be freed.
			const char *propertyNameCString = [propertyName UTF8String];
			
			// Get this class's property metadata. This array needs to be freed.
			objc_property_t *properties = class_copyPropertyList(myClass, &outCount);
			
			// Find the property with the provided name.
			for (int i = 0; i < outCount; i++)
			{
				// Get the property.
				objc_property_t property = properties[i];
				
				// This is the property - get its attributes.
				const char *attributes = property_getAttributes(property);
				
				// Copy the attributes into a mutable representation.
				char *mutableAttributes = (char *)malloc(strlen(attributes) * sizeof(char));
				strcpy(mutableAttributes, attributes);
				
				// Create the property info.
				AFPropertyInfo *propertyInfo = [[AFPropertyInfo alloc]
					init];
				
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
							
							propertyInfo.propertyType = [[NSString stringWithUTF8String: token] copy];
							
							break;
						}
						case 'G':
						{
							// Advance past the type marker.
							token++;
							
							propertyInfo.customGetterSelectorName = [[NSString stringWithUTF8String: token] copy];
							
							break;
						}
						case 'S':
						{
							// Advance past the type marker.
							token++;
							
							propertyInfo.customSetterSelectorName = [[NSString stringWithUTF8String: token] copy];
							
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
				
					// Get the property name.
					const char *testPropertyNameCString = property_getName(property);
					NSString *testPropertyName = [[NSString stringWithUTF8String: testPropertyNameCString] copy];
					
					// Set the property info name.
					propertyInfo.propertyName = testPropertyName;
					
					// Cache the property info.
					propertyInfoMap[testPropertyName] = propertyInfo;
					
					// Get the next token.
					token = strtok(NULL, mutableAttributes);
					
					// Set the result.
					if (strcmp(propertyNameCString, testPropertyNameCString) == 0)
					{
						result = propertyInfo;
					}
				}
				
				// Free the mutable attributes.
				if (mutableAttributes != NULL)
				{
					free(mutableAttributes);
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
}

- (void)_setHasOneValue: (id)value
	target: (id)target
	propertyName: (NSString *)propertyName
	provider: (AFObjectProvider *)provider
{
	// Get the property info - has one relationships are defined by their property type.
	AFPropertyInfo *propertyInfo = [self _propertyInfoForClass: [target class]
		propertyName: propertyName];
	
	// Attempt to transform the value.
	id transformedValue = [self transformValue: value
		toClass: propertyInfo.propertyClass
		provider: provider];
	
	// TODO: remove.
	if (propertyInfo.propertyClass != nil
		&& propertyInfo.propertyClass == [transformedValue class])
	{
		// Set the property directly.
		[target setValue: transformedValue
			forKeyPath: propertyName];
	}
	else
	{
		AFLog(AFLogLevelDebug, @"Skipping invalid assignment: %@ to property: %@",
			transformedValue, propertyName);
	}
}
	
- (void)_setHasManyValue: (id)value
	target: (id)target
	propertyName: (NSString *)propertyName
	provider: (AFObjectProvider *)provider
{
	// Get the property info - this is used to determine collection type for has-many relationships.
	AFPropertyInfo *propertyInfo = [self _propertyInfoForClass: [target class]
		propertyName: propertyName];
	
	// Assign to read-only properties.
	BOOL needsAssignment = propertyInfo.isReadonly == NO;
	
	// Generate a mutable collection suitable for either assignment or update.
	id mutableCollection = needsAssignment
		? [self _mutableCollectionWithClassName: propertyInfo.propertyClassName]
		: [self _mutableCollectionForTarget: target
			propertyClassName: propertyInfo.propertyClassName
			propertyName: propertyName];

	// Set value if it is not null.
	if (AFIsNull(value) == NO)
	{
		// Ignore any non-array values. TODO: Fail in debug.
		if ([value isKindOfClass: NSArray.class] == NO)
		{
			// Clear the collection, before assignment.
			[mutableCollection removeAllObjects];
		
			// Add each transformed item.
			for (id item in value)
			{
				// Transform each item.
				id transformedItem = [self transformValue: item
					toClass: _hasManyClass
					provider: provider];
					
				// Add the item to the mutable collection.
				[mutableCollection addObject: transformedItem];
			}
			
			// Assign the collection, if required.
			if (needsAssignment)
			{
				[target setValue: mutableCollection
					forKeyPath: propertyName];
			}
		}
		else
		{
			// Ignore non-array values. TODO: Fail in debug.
		}
	}
	else
	{
		// For nil / NSNull values, clear the mutable collection.
		if (needsAssignment)
		{
			// Assign the empty collection.
			[target setValue: mutableCollection
				forKeyPath: propertyName];
		}
		else
		{
			// Clear the non-assigned collection.
			[mutableCollection removeAllObjects];
		}
	}
}

- (id)_mutableCollectionForTarget: (id)target
	propertyClassName: (NSString *)propertyClassName
	propertyName: (NSString *)propertyName
{
	if ([propertyClassName isEqualToString: @"NSOrderedSet"])
	{
		return [target mutableOrderedSetValueForKeyPath: propertyName];
	}
	else if ([propertyClassName isEqualToString: @"NSSet"])
	{
		return [target mutableSetValueForKeyPath: propertyName];
	}
	else if ([propertyClassName isEqualToString: @"NSArray"])
	{
		return [target mutableArrayValueForKeyPath: propertyName];
	}
	else if ([propertyClassName isEqualToString: @"NSMutableArray"]
		|| [propertyClassName isEqualToString: @"NSMutableSet"]
		|| [propertyClassName isEqualToString: @"NSMutableOrderedSet"])
	{
		// Get mutable collection property values.
		return [target valueForKeyPath: propertyName];
	}
	
	// Class name didn't match any supported collection.
	return nil;
}

- (id)_mutableCollectionWithClassName: (NSString *)className
{
	if ([className isEqualToString: @"NSMutableArray"]
		|| [className isEqualToString: @"NSArray"])
	{
		return [[NSMutableArray alloc]
			init];
	}
	else if ([className isEqualToString: @"NSMutableSet"]
		|| [className isEqualToString: @"NSSet"])
	{
		return [[NSMutableSet alloc]
			init];
	}
	else if ([className isEqualToString: @"NSMutableOrderedSet"]
		|| [className isEqualToString: @"NSMutableSet"])
	{
		return [[NSMutableOrderedSet alloc]
			init];
	}
	
	// Class name didn't match any supported collection.
	return nil;
}

@end