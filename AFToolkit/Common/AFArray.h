

#pragma mark Class Interface

@interface AFArray : NSObject<
	NSFastEnumeration,
	NSCoding>
{
	@protected NSMutableArray *_objects;
}


#pragma mark - Properties

@property (nonatomic, readonly) NSArray *objects;


#pragma mark - Constructors

- (id)init;

- (id)initWithCapacity: (NSUInteger)numItems;

- (id)initWithArray: (NSArray *)array;

+ (instancetype)array;

+ (instancetype)arrayWithCapacity: (NSUInteger)numItems;

+ (instancetype)arrayWithArray: (NSArray *)array;


#pragma mark - Array KVO Methods

- (NSUInteger)countOfObjects;

- (id)objectInObjectsAtIndex: (NSUInteger)index;

- (NSArray *)objectsAtIndexes: (NSIndexSet *)indexes;


#pragma mark - Set KVO Methods

- (NSEnumerator *)enumeratorOfObjects;


#pragma mark - Public Methods

- (NSUInteger)count;

- (BOOL)containsObject: (id)object;


@end