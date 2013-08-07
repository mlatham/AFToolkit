#import "AFObjectProvider.h"


#pragma mark Class Variables

static __strong NSMutableDictionary *_objectModels;


#pragma mark - Class Definition

@implementation AFObjectProvider


#pragma mark - Constructors

+ (void)initialize
{
	static BOOL classInitialized = NO;
	
	if (classInitialized == NO)
	{
		_objectModels = [[NSMutableDictionary alloc]
			init];
	
		classInitialized = YES;
	}
}


#pragma mark - Public Methods

+ (void)registerObjectModel: (AFObjectModel *)objectModel
{
	[_objectModels setObject: objectModel
		forKey: (id <NSCopying>)objectModel.myClass];
}

+ (AFObjectModel *)objectModelForClass: (Class)myClass
{
	return [_objectModels objectForKey: (id <NSCopying>)myClass];
}

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
	AFObjectModel *objectModel = [AFObjectProvider objectModelForClass: myClass];
	
	id instance = nil;
	
	// Get an object model for this class.
	if (AFIsNull(objectModel) == NO)
	{
		// Use the create block, if specified.
		if (AFIsNull(objectModel.createBlock) == NO)
		{
			AFObjectCreateBlock createBlock = [objectModel.createBlock copy];
		
			instance = createBlock(self);
		}
		// Otherwise, allocate a new instance using the default constructor.
		else
		{
			instance = [[myClass alloc]
				init];
		}
	}
	
	return instance;
}

- (void)update: (id)object
	withValues: (NSDictionary *)values
{
	Class myClass = [object class];

	AFObjectModel *objectModel = [AFObjectProvider objectModelForClass: myClass];
	
	// Apply the mapped values, if present.
	if (AFIsNull(objectModel.propertyKeyMap) == NO)
	{
		for (NSString *key in [objectModel.propertyKeyMap allKeys])
		{
			// If a mapping exists, set the value.
			id propertyKeyPath = [objectModel.propertyKeyMap objectForKey: key];
			if (propertyKeyPath != nil)
			{
				id value = [values objectForKey: key];
				if (value == [NSNull null])
				{
					// Clear value on NSNull.
					[object setValue: nil
						forKeyPath: propertyKeyPath];
				}
				else if (value != nil)
				{
					// Set value otherwise.
					[object setValue: value
						forKeyPath: propertyKeyPath];
				}
				else
				{
					// Otherwise, no value was defined - don't set anything.
				}
			}
		}
	}
	
	// Apply the update block, if present.
	if (AFIsNull(objectModel.updateBlock) == NO)
	{
		AFObjectUpdateBlock updateBlock = [objectModel.updateBlock copy];
		
		// Apply the values.
		updateBlock(self, object, values);
	}
}


@end // @implementation AFObjectProvider