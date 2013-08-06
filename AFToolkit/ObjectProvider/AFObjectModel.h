

#pragma mark Forward Declarations

@class AFObjectProvider;


#pragma mark Type Definitions

typedef void (^AFObjectUpdateBlock)(AFObjectProvider *provider, id object, NSDictionary *values);

typedef id (^AFObjectCreateBlock)(AFObjectProvider *provider, NSDictionary *values);


#pragma mark - Class Interface

@interface AFObjectModel : NSObject


#pragma mark - Properties

@property (nonatomic, strong) Class class;

@property (nonatomic, copy) NSArray *idProperties;

@property (nonatomic, copy) NSDictionary *propertyKeyMap;
@property (nonatomic, copy) NSDictionary *collectionTypeMap;

@property (nonatomic, copy) AFObjectUpdateBlock updateBlock;
@property (nonatomic, copy) AFObjectCreateBlock createBlock;


#pragma mark - Constructors

- (id)initWithClass: (Class)class
	idProperties: (NSArray *)idProperties
	propertyKeyMap: (NSDictionary *)propertyKeyMap
	collectionTypeMap: (NSDictionary *)collectionTypeMap
	updateBlock: (AFObjectUpdateBlock)updateBlock
	createBlock: (AFObjectCreateBlock)createBlock;


#pragma mark - Static Methods

+ (id)objectModelWithClass: (Class)class
	idProperties: (NSArray *)idProperties
	propertyKeyMap: (NSDictionary *)propertyKeyMap
	collectionTypeMap: (NSDictionary *)collectionTypeMap
	updateBlock: (AFObjectUpdateBlock)updateBlock
	createBlock: (AFObjectCreateBlock)createBlock;


@end // @interface AFObjectModel