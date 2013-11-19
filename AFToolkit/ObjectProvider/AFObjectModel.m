#import "AFObjectModel.h"
#import <objc/runtime.h>


#pragma mark Constants

// Use the addresses as the key.
static char OBJECT_MODEL_MAP_KEY;


#pragma mark Class Definition

@implementation AFObjectModel


#pragma mark - Constructors

- (id)initWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relationships: (NSDictionary *)relationships
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_idKeyPaths = idKeyPaths;
	_collectionKey = collectionKey;
	_rootKey = rootKey;
	_relationships = relationships;
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: idKeyPaths
		collectionKey: collectionKey
		rootKey: rootKey
		relationships: relationships];
}

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	collectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: @[ idKeyPath ]
		collectionKey: collectionKey
		rootKey: rootKey
		relationships: relationships];
}

+ (instancetype)objectModelWithCollectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relatioships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: nil
		collectionKey: collectionKey
		rootKey: rootKey
		relationships: relationships];
}

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: idKeyPaths
		collectionKey: nil
		rootKey: nil
		relationships: relationships];
}

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: @[ idKeyPath ]
		collectionKey: nil
		rootKey: nil
		relationships: relationships];
}

+ (instancetype)objectModelWithRelationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: nil
		collectionKey: nil
		rootKey: nil
		relationships: relationships];
}

+ (instancetype)objectModelForClass: (Class)myClass
{
	AFObjectModel *objectModel = nil;
	
	// Only try to get the object model if the class is set.
	if (AFIsNull(myClass) == NO)
	{
		NSString *myClassName = NSStringFromClass(myClass);

		NSMutableDictionary *objectModelMap = [self _objectModelMap];
		
		objectModel = objectModelMap[myClassName];
		
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