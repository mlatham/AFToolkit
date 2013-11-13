#import "AFObjectProvider.h"
#import "NSObject+Runtime.h"
#import "AFValueTransformer.h"


#pragma mark Class Definition

@implementation AFObjectProvider


#pragma mark - Public Methods

- (id)create: (Class)myClass
	withValues: (NSDictionary *)values
{	
	id instance = [self create: myClass];
	
	// Get an object model for this class.
	if (AFIsNull(instance) == NO)
	{
		// Update the object.
		[self update: instance
			withValues: values];
	}
	
	return instance;
}

- (id)create: (Class)myClass
{
	// By default, just allocate and init the class.
	id instance = [[myClass alloc]
		init];
	
	return instance;
}

- (void)update: (id)object
	withValues: (NSDictionary *)values
{
	Class myClass = [object class];
	id myClassObject = (id)myClass;
	
	if ([myClassObject conformsToProtocol: @protocol(AFObjectModel)] == YES)
	{
		// Get the mapped values.
		NSDictionary *valueKeyPathsByPropertyKeyPath = [myClassObject valueKeyPathsByPropertyKeyPath];
		
		// Apply the mapped values, if present.
		if (AFIsNull(valueKeyPathsByPropertyKeyPath) == NO)
		{
			for (NSString *propertyKeyPath in [valueKeyPathsByPropertyKeyPath allKeys])
			{
				// If a mapping exists, set the value.
				id valueKeyPath = valueKeyPathsByPropertyKeyPath[propertyKeyPath];
				
				if (AFIsNull(valueKeyPath) == NO)
				{
					id value = values[valueKeyPath];
					
					// Value is nil - no value was defined, so set nothing. (NSNull is an empty value).
					if (value != nil)
					{
						AFValueTransformer *transformer = nil;
						
						if ([myClassObject respondsToSelector: @selector(transformersByPropertyKeyPath)] == YES)
						{
							// Get the transformers map.
							NSDictionary *transformers = [myClassObject transformersByPropertyKeyPath];
							
							if (transformers != nil)
							{
								// Try to get the transformer.
								transformer = transformers[propertyKeyPath];
							}
						}
						
						// Don't crash on failing a parse/set.
						@try
						{
							// Set value otherwise.
							[self _setValue: value
								target: object
								propertyName: propertyKeyPath
								transformer: transformer];
						}
						@catch (NSException *exception)
						{
							NSLog(@"Failed to parse value: %@ for property: %@. Error: %@", value, propertyKeyPath, exception);
						}
					}
				}
			}
		}
	}
	
	// Call the update method, if implemented.
	if ([myClassObject respondsToSelector: @selector(update:values:provider:)] == YES)
	{
		[myClassObject update: object
			values: values
			provider: self];
	}
}


#pragma mark - Private Methods

// Sets a value on this object, changing NSNull values to nil, applying the provided
// transform, handling setting one or many values on a collection type property of
// either NSMutableSet, NSMutableArray or NSMutableOrderedSet.

- (void)_setValue: (id)value
	target: (id)target
	propertyName: (NSString *)propertyName
	transformer: (AFValueTransformer *)transformer
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
		NSArray *collectionClasses = @[
			@"NSMutableArray",
			@"NSMutableOrderedSet",
			@"NSMutableSet",
			@"AFMutableArray"
		];
		
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
			id set = [target _mutableCollectionWithClassName: propertyClassName
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
			id set = [target _mutableCollectionWithClassName: propertyClassName
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

- (id)_transformValue: (id)value
	transformer: (AFValueTransformer *)transformer
{
	// Transform or use the original value.
	id transformedValue = AFIsNull(transformer) == NO
		? [transformer transform: value provider: self]
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