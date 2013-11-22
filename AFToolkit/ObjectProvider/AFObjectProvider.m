#import "NSObject+Runtime.h"
#import "AFObjectProvider.h"
#import "AFRelationship.h"


#pragma mark Class Definition

@implementation AFObjectProvider


#pragma mark - Public Methods

- (id)create: (Class)myClass
{
	// By default, just allocate and init the class.
	id instance = [[myClass alloc]
		init];
	
	return instance;
}

- (id)create: (Class)myClass
	values: (NSDictionary *)values
{
	// Create an instance.
	id instance = [self create: myClass];
	
	// Update the instance, if created.
	if (AFIsNull(instance) == NO)
	{
		[self update: instance
			values: values];
	}
	
	return instance;
}

- (id)fetch: (Class)myClass
	values: (NSDictionary *)values
{
	// By default, this provider does no identity mapping. Return nil.
	return nil;
}

- (id)fetchOrCreate: (Class)myClass
	idValue: (NSString *)idValue
{
	id instance = nil;

	AFObjectModel *objectModel = [AFObjectModel objectModelForClass: myClass];
	
	if ([objectModel.idKeyPaths count] != 1)
	{
#if defined(DEBUG_OBJECT_PROVIDER)
		AFLog(AFLogLevelDebug, @"AFObjectProvider: Object model must define exactly one idKeyPath for fetchOrCreate");
#endif
	}
	else if (AFIsNull(idValue) == NO)
	{
		// Form a fetch request with the object's key value.
		NSDictionary *values =
		@{
			objectModel.idKeyPaths[0] : idValue
		};
		
		// Fetch the instance.
		instance = [self fetch: myClass
			values: values];
	
		// Create the instance, if it didn't exist.
		if (AFIsNull(instance) == YES)
		{
			instance = [self create: myClass
				values: values];
		}
	}
	
	return instance;
}

- (id)updateOrCreate: (Class)myClass
	values: (NSDictionary *)values
{
	// Try to fetch an existing instance.
	id instance = [self fetch: myClass
		values: values];
	
	// Create the instance, if it wasn't found.
	if (AFIsNull(instance) == YES)
	{
		instance = [self create: myClass];
	}
	
	// Update the instance, if it exists.
	if (AFIsNull(instance) == NO)
	{
		[self update: instance
			values: values];
	}
	
	return instance;
}

- (void)update: (id)object
	values: (NSDictionary *)values
{
	Class myClass = [object class];
	
	id myClassObject = (id)myClass;
	
	// Object models are cached by the AFObjectModel class.
	AFObjectModel *objectModel = [AFObjectModel objectModelForClass: myClass];
	
	if (objectModel != nil)
	{
		// Get the mapped values.
		NSDictionary *relationshipsByPropertyKeyPath = objectModel.relationships;
		
		// Apply the mapped values, if present.
		if (relationshipsByPropertyKeyPath != nil)
		{
			for (NSString *propertyKeyPath in [relationshipsByPropertyKeyPath allKeys])
			{
				// If a mapping exists and is valid, set the value.
				id relationship = relationshipsByPropertyKeyPath[propertyKeyPath];
				
				if (AFIsNull(relationship) == NO
					&& [relationship isKindOfClass: AFRelationship.class])
				{
					// Don't crash on failing a parse/set.
					@try
					{
						// Use the relationship to get and set the value.
						[relationship update: object
							values: values
							propertyName: propertyKeyPath
							provider: self];
					}
					@catch (NSException *exception)
					{
#if defined(DEBUG_OBJECT_PROVIDER)
						AFLog(AFLogLevelDebug, @"Failed to parse value for property: %@. Error: %@", propertyKeyPath, exception);
#endif
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


@end