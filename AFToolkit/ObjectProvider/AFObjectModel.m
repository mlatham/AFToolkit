#import "AFObjectModel.h"
#import <objc/runtime.h>


#pragma mark Constants

// Use the addresses as the key.
static char OBJECT_MODEL_MAP_KEY;


#pragma mark Class Definition

@implementation AFObjectModel


#pragma mark - Constructors

- (id)initWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_key = key;
	_mappings = mappings;
	_transformers = transformers;
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

+ (id)objectModelWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers
{
	return [[AFObjectModel alloc]
		initWithKey: key
		mappings: mappings
		transformers: transformers];
}

+ (id)objectModelWithMappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers
{
	return [[AFObjectModel alloc]
		initWithKey: nil
		mappings: mappings
		transformers: transformers];
}

+ (id)objectModelWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
{
	return [[AFObjectModel alloc]
		initWithKey: key
		mappings: mappings
		transformers: nil];
}

+ (id)objectModelWithMappings: (NSDictionary *)mappings
{
	return [[AFObjectModel alloc]
		initWithKey: nil
		mappings: mappings
		transformers: nil];
}

+ (id)objectModelForClass: (Class)myClass
{
	NSString *myClassName = NSStringFromClass(myClass);

	NSMutableDictionary *objectModelMap = [self _objectModelMap];
	
	AFObjectModel *objectModel = objectModelMap[myClassName];
	
	// Create the object models on demand.
	if (objectModel == nil)
	{
		id myClassObject = (id)myClass;
		
		if ([myClassObject respondsToSelector: @selector(objectModel)])
		{
			objectModel = [myClassObject objectModel];
			
			// Cache each object model by class name.
			objectModelMap[myClassName] = objectModel;
		}
	}
	
	return objectModel;
}


#pragma mark - Private Methods

+ (NSMutableDictionary *)_objectModelMap
{
	NSMutableDictionary *objectModelMap = (NSMutableDictionary *)objc_getAssociatedObject(self, &OBJECT_MODEL_MAP_KEY);
	
	// Create the property info map on demand.
	if (objectModelMap == nil)
	{
		objectModelMap = [NSMutableDictionary dictionary];
	
		[self _setObjectModelMap: objectModelMap];
	}
	
	return objectModelMap;
}

+ (void)_setObjectModelMap: (NSMutableDictionary *)propertyInfoMap
{
	objc_setAssociatedObject(self, &OBJECT_MODEL_MAP_KEY, propertyInfoMap, OBJC_ASSOCIATION_RETAIN);
}


@end