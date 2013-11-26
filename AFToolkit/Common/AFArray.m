#import "AFArray.h"


#pragma mark Class Definition

@implementation AFArray


#pragma mark - Constructors

- (id)init
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	_objects = [[NSMutableArray alloc]
		init];
	
	return self;
}

- (id)initWithCapacity: (NSUInteger)numItems
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	_objects = [[NSMutableArray alloc] 
		initWithCapacity: numItems];
	
	return self;
}

- (id)initWithArray: (NSArray *)array
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	_objects = [array mutableCopy];
	
	return self;
}

+ (instancetype)array
{
	return [[self alloc]
		init];
}

+ (instancetype)arrayWithCapacity: (NSUInteger)numItems
{
	return [[self alloc]
		initWithCapacity: numItems];
}

+ (instancetype)arrayWithArray: (NSArray *)array
{
	return [[self alloc]
		initWithArray: array];
}


#pragma mark - NSCoding Protocol Methods

- (id)initWithCoder: (NSCoder *)aDecoder
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	_objects = [[aDecoder decodeObjectForKey: @"objects"]
		mutableCopy];
	
	return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder
{
	[aCoder encodeObject: _objects 
		forKey: @"objects"];
}


#pragma mark - NSFastEnumeration Protocol Methods

- (NSUInteger)countByEnumeratingWithState: (NSFastEnumerationState *)state
	objects: (__unsafe_unretained id *)stackbuf
	count: (NSUInteger)len
{
	// Use NSArray's implementation of fast enumeration.
	return [_objects countByEnumeratingWithState: state 
		objects: (__unsafe_unretained id *)stackbuf 
		count: len];
}


#pragma mark - Array KVO Methods

- (NSUInteger)countOfObjects
{
	return [_objects count];
}

- (id)objectInObjectsAtIndex: (NSUInteger)index
{
	return [_objects objectAtIndex: index];
}

- (NSArray *)objectsAtIndexes: (NSIndexSet *)indexes
{
	return [_objects objectsAtIndexes: indexes];
}


#pragma mark - Set KVO Methods

- (NSEnumerator *)enumeratorOfObjects
{
	return [_objects objectEnumerator];
}


#pragma mark - Public Methods

- (NSUInteger)count
{
	return [_objects count];
}

- (BOOL)containsObject: (id)object
{
	return [_objects containsObject: object];
}


@end