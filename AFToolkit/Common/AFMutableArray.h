#import "AFArray.h"


#pragma mark Class Interface

@interface AFMutableArray : AFArray


#pragma mark - Properties

- (void)setObjects: (NSArray *)objects;


#pragma mark - Constructors

+ (AFMutableArray *)array;

+ (AFMutableArray *)arrayWithCapacity: (NSUInteger)numItems;

+ (AFMutableArray *)arrayWithArray: (NSArray *)array;


#pragma mark - Mutable Array KVO Methods

- (void)insertObject: (id)object
   inObjectsAtIndex: (NSUInteger)index;

- (void)insertObjects: (NSArray *)objectsArray
	atIndexes: (NSIndexSet *)indexes;

- (void)removeObjectFromObjectsAtIndex: (NSUInteger)index;

- (void)removeObjectsAtIndexes: (NSIndexSet *)indexes;

- (void)replaceObjectAtIndex: (NSUInteger)index 
	withObject: (id)anObject;


#pragma mark - Set KVO Methods

- (void)addObject: (id)object;

- (void)removeObject: (id)object;


#pragma mark - Public Methods

- (void)removeAllObjects;


@end