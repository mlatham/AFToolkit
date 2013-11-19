#import "AFRelationship.h"
#import "NSObject+Runtime.h"


#pragma mark Static Variables

static NSArray *_collectionClasses;


#pragma mark - Class Definition

@implementation AFRelationship
{
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


#pragma mark - Public Methods

+ (id)key: (NSString *)key
{
	return [[AFRelationship alloc]
		initWithKeys: @[ key ]];
}

+ (id)keys: (NSArray *)keys
{
	return [[AFRelationship alloc]
		initWithKeys: keys];
}

+ (id)hasMany: (Class)hasManyClass
	keys: (NSArray *)keys
{
	return [[AFRelationship alloc]
		initWithHasMany: hasManyClass
		keys: keys];
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
		value = values[key];
		
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

- (void)_setHasOneValue: (id)value
	target: (id)target
	propertyName: (NSString *)propertyName
	provider: (AFObjectProvider *)provider
{
	// Get the property info - has one relationships are defined by their property type.
	AFPropertyInfo *propertyInfo = [[target class] propertyInfoForPropertyName: propertyName];
	
	// Attempt to transform the value.
	id transformedValue = [self transformValue: value
		toClass: propertyInfo.propertyClass
		provider: provider];
	
	// Set the property directly.
	[target setValue: transformedValue
		forKeyPath: propertyName];
}

- (void)_setHasManyValue: (id)value
	target: (id)target
	propertyName: (NSString *)propertyName
	provider: (AFObjectProvider *)provider
{
	// Get the property info - this is used to determine collection type for has-many relationships.
	AFPropertyInfo *propertyInfo = [[target class] propertyInfoForPropertyName: propertyName];
	
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