

#pragma mark Forward Declaration

@class AFObjectModel;


#pragma mark AFObjectModel Protocol

@protocol AFObjectModel<NSObject>

@required

+ (AFObjectModel *)objectModel;

@optional

+ (void)update: (id)value
	values: (NSDictionary *)values
	provider: (id)provider;

@end


#pragma mark - Class Interface

@interface AFObjectModel : NSObject


#pragma mark - Properties

// Keypath of the model object defining identity (or nil).
@property (nonatomic, strong, readonly) NSString *idKeyPath;

// Root and collection keys when applying values.
@property (nonatomic, strong, readonly) NSArray *collectionKeys;
@property (nonatomic, strong, readonly) NSArray *rootKeys;

// Relationships by keypath.
@property (nonatomic, strong, readonly) NSDictionary *relationships;


#pragma mark - Constructors

- (id)initWithIDKeyPath: (NSString *)idKeyPath
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships;


#pragma mark - Static Methods

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	collectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithCollectionKeys: (NSArray *)collectionKeys
	rootKeys: (NSArray *)rootKeys
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithIDKeyPath: (NSString *)idKeyPath
	relationships: (NSDictionary *)relationships;

+ (instancetype)objectModelWithRelationships: (NSDictionary *)relationships;

+ (instancetype)objectModelForClass: (Class)myClass;

// Dictionary of object models by class name (NSString).
+ (NSDictionary *)objectModels;

// Registers the object model classes.
+ (void)registerClasses: (NSArray *)classes;

// Gets the id for a model, if defined.
+ (NSString *)idForModel: (NSObject<AFObjectModel> *)model;


@end