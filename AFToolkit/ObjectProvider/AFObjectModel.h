

#pragma mark Class Interface

@interface AFObjectModel : NSObject


#pragma mark - Properties

// Keypath of the model object defining identity (or nil).
@property (nonatomic, strong, readonly) NSArray *idKeyPaths;

// Root and collection keys when applying values.
@property (nonatomic, strong, readonly) NSString *collectionKey;
@property (nonatomic, strong, readonly) NSString *rootKey;

// Relationships by keypath.
@property (nonatomic, strong, readonly) NSDictionary *relationships;


#pragma mark - Constructors

- (id)initWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relationships: (NSDictionary *)relationships;


#pragma mark - Static Methods

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	collectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	collectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithCollectionKey: (NSString *)collectionKey
	rootKey: (NSString *)rootKey
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithIDKeyPaths: (NSArray *)idKeyPaths
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithRelationships: (NSDictionary *)relationships;

+ (instancetype)objectModelForClass: (Class)myClass;

// Dictionary of object models by class.
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