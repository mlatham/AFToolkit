

#pragma mark Class Interface

@interface AFObjectModel : NSObject


#pragma mark - Properties

@property (nonatomic, strong, readonly) NSArray *key;
@property (nonatomic, strong, readonly) NSDictionary *mappings;
@property (nonatomic, strong, readonly) NSDictionary *transformers;


#pragma mark - Constructors

- (id)initWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers;


#pragma mark - Static Methods

+ (id)objectModelWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers;

+ (id)objectModelWithMappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers;

+ (id)objectModelWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings;

+ (id)objectModelWithMappings: (NSDictionary *)mappings;


@end


#pragma mark AFObjectModel Protocol

@protocol AFObjectModel<NSObject>

@required

- (AFObjectModel *)objectModel;

@optional

+ (void)update: (id)value
	values: (NSDictionary *)values
	provider: (id)provider;

@end