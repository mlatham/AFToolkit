#import "AFObjectModel.h"


#pragma mark Constants

static __strong NSMutableDictionary *_objectModelsByClassName;


#pragma mark Class Definition

@implementation AFObjectModel
{
	@private __strong NSArray *_rootKeys;
	@private __strong NSArray *_idKeyPaths;
	@private __strong NSArray *_collectionKeys;
	@private __strong NSDictionary *_relationships;
}


#pragma mark - Constructors

- (id)initWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_rootKeys = [rootKeys copy];
	_idKeyPaths = [idKeyPaths copy];
	_collectionKeys = [collectionKeys copy];
	_relationships = [relationships copy];
	
	// Return initialized instance.
	return self;
}

+ (void)initialize
{
	static BOOL _classInitialized = NO;
	
	if (_classInitialized == NO)
	{
		// Initialize the static object model dictionary.
		_objectModelsByClassName = [[NSMutableDictionary alloc]
			init];
	
		_classInitialized = YES;
	}
}


#pragma mark - Public Methods

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: idKeyPaths
		collectionKeys: collectionKeys
		rootKeys: rootKeys
		relationships: relationships];
}

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: @[ idKeyPath ]
		collectionKeys: collectionKeys
		rootKeys: rootKeys
		relationships: relationships];
}

+ (instancetype)objectModelWithCollectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: nil
		collectionKeys: collectionKeys
		rootKeys: rootKeys
		relationships: relationships];
}

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: idKeyPaths
		collectionKeys: nil
		rootKeys: nil
		relationships: relationships];
}

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	relationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: @[ idKeyPath ]
		collectionKeys: nil
		rootKeys: nil
		relationships: relationships];
}

+ (instancetype)objectModelWithRelationships: (NSDictionary *)relationships
{
	return [[self alloc]
		initWithIDKeyPaths: nil
		collectionKeys: nil
		rootKeys: nil
		relationships: relationships];
}

+ (instancetype)objectModelForClass: (Class)myClass
{
	AFObjectModel *objectModel = nil;
	
	// Only try to get the object model if the class is set.
	if (AFIsNull(myClass) == NO)
	{
		NSString *myClassName = NSStringFromClass(myClass);
		
		objectModel = _objectModelsByClassName[myClassName];
		
		// Create the object models on demand.
		if (objectModel == nil)
		{
			id myClassObject = (id)myClass;
			
			if ([myClassObject conformsToProtocol: @protocol(AFObjectModel)])
			{
				objectModel = [myClassObject objectModel];
				
				// Cache each object model by class name.
				_objectModelsByClassName[myClassName] = objectModel;
			}
		}
	}
	
	return objectModel;
}

+ (NSDictionary *)objectModels
{
	return [_objectModelsByClassName copy];
}


@end