

#pragma mark Class Interface

@interface AFObjectModel : NSObject


#pragma mark - Properties

// Keypath of the model object defining identity (or nil).
@property (nonatomic, strong, readonly) NSArray *idKeyPaths;

// Root and collection keys when applying values.
@property (nonatomic, strong, readonly) NSArray *collectionKeys;
@property (nonatomic, strong, readonly) NSArray *rootKeys;

// Relationships by keypath.
@property (nonatomic, strong, readonly) NSDictionary *relationships;


#pragma mark - Constructors

- (id)initWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships;


#pragma mark - Static Methods

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithCollectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithRelationships: (NSDictionary *)relationships;

+ (instancetype)objectModelForClass: (Class)myClass;

// Dictionary of object models by class name (NSString).
+ (NSDictionary *)objectModels;


@end


#pragma mark AFObjectModel Protocol

@protocol AFObjectModel<NSObject>

@required

+ (AFObjectModel *)objectModel;

@optional

+ (void)update: (id)value
	values: (NSDictionary *)values
	provider: (id)provider;

@end