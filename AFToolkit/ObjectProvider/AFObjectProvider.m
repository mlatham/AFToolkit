#import "AFObjectProvider.h"
#import "NSObject+Runtime.h"


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
						NSValueTransformer *transformer = nil;
						
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
							[object setValue: value
								forPropertyName: propertyKeyPath
								withTransformer: transformer];
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
	if ([myClassObject respondsToSelector: @selector(update:withValues:)] == YES)
	{
		[myClassObject update: object
			withValues: values];
	}
}


#pragma mark - Private Methods

+ (void)_setValue: (id)value
	withTransformer: (NSValueTransformer *)transformer
	withKeyPath: (NSString *)keyPath
	onObject: (id)object
{
	// Get the property attributes about the keypath.
	
	// The property is a collection property.
	
	// The property is not a collection property.
	
}


@end