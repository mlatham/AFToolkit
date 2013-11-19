#import "AFObjectProvider.h"


#pragma mark Enumerations

typedef enum
{
	AFRelationshipTypeHasOne,
	AFRelationshipTypeHasMany,

} AFRelationshipType;


#pragma mark Class Interface

@interface AFRelationship : NSObject


#pragma mark - Properties

@property (nonatomic, assign, readonly) AFRelationshipType type;
@property (nonatomic, strong, readonly) NSArray *keys;


#pragma mark - Constructors

- (id)initWithKeys: (NSArray *)keys;

- (id)initWithHasMany: (Class)hasManyClass
	keys: (NSArray *)keys;


#pragma mark - Static Methods

// Returns a relationship that resolves a single object or value and sets its value.
+ (instancetype)key: (NSString *)key;
+ (instancetype)keys: (NSArray *)keys;

// Returns a relationship that resolves one or many object instances and assigns them to a collection.
+ (instancetype)hasMany: (Class)hasManyClass
	keys: (NSArray *)keys;
+ (instancetype)hasMany: (Class)hasManyClass
	key: (NSString *)key;


#pragma mark - Instance Methods

// Update the target object with a set of values.
- (void)update: (id)object
	values: (NSDictionary *)values
	propertyName: (NSString *)propertyName
	provider: (AFObjectProvider *)provider;

// Transform a value.
- (id)transformValue: (id)value
	toClass: (Class)toClass
	provider: (AFObjectProvider *)provider;


@end