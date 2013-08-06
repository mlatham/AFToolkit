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
		forKey: (id <NSCopying>)objectModel.class];
}

- (id)createInstanceOf: (Class)class
	withValues: (NSDictionary *)values
{
	AFObjectModel *objectModel = [self _objectModelForClass: class];
	
	id instance = nil;
	
	// Get an object model for this class.
	if (AFIsNull(objectModel) == NO)
	{
		AFObjectCreateBlock createBlock = [objectModel.createBlock copy];
		
		// Create the instance.
		instance = createBlock(self, values);
		
		// Update the object.
		[self updateObject: instance
			withValues: values];
	}
	
	return instance;
}

- (void)updateObject: (id)object
	withValues: (NSDictionary *)values
{
	Class class = [object class];

	AFObjectModel *objectModel = [self _objectModelForClass: class];
	
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


#pragma mark - Private Methods

- (AFObjectModel *)_objectModelForClass: (Class)class
{
	return [_objectModels objectForKey: class];
}


@end // @implementation AFObjectProvider