#import "AFMutableArray.h"


#pragma mark Class Definition

@implementation AFMutableArray


#pragma mark - Properties

- (void)setObjects: (NSArray *)objects
{
	// NOTE: copy properties will copy objects as immutable.
	_objects = [objects mutableCopy];
}


#pragma mark - Constructors

+ (AFMutableArray *)array
{
	return [[AFMutableArray alloc]
		init];
}

+ (AFMutableArray *)arrayWithCapacity: (NSUInteger)numItems
{
	return [[AFMutableArray alloc]
		initWithCapacity: numItems];
}

+ (AFMutableArray *)arrayWithArray: (NSArray *)array
{
	return [[AFMutableArray alloc]
		initWithArray: array];
}


#pragma mark - Array KVO Methods

- (void)insertObject: (id)object
   inObjectsAtIndex: (NSUInteger)index
{
	[_objects insertObject: object 
		atIndex: index];
}

- (void)insertObjects: (NSArray *)objectsArray
	atIndexes: (NSIndexSet *)indexes
{
	[_objects insertObjects: objectsArray 
		atIndexes: indexes];
}

- (void)removeObjectFromObjectsAtIndex: (NSUInteger)index
{
	[_objects removeObjectAtIndex: index];
}

- (void)removeObjectsAtIndexes: (NSIndexSet *)indexes
{
	[_objects removeObjectsAtIndexes: indexes];
}

- (void)replaceObjectAtIndex: (NSUInteger)index 
	withObject: (id)anObject
{
	[_objects replaceObjectAtIndex: index 
		withObject: anObject];
}


#pragma mark - Set KVO Methods

- (void)addObject: (id)object
{
	[self insertObject: object 
		inObjectsAtIndex: _objects.count];
}

- (void)removeObject: (id)object
{
	[self removeObjectFromObjectsAtIndex:
		[_objects indexOfObject: object]];
}


#pragma mark - Public Methods

- (void)removeAllObjects
{
	// Clear objects by setting the objects array.
	self.objects = [NSMutableArray array];
}


@end