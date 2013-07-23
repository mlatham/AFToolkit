#import "AFArrayView.h"
#import "AFKVO.h"


#pragma mark Class Extension

@interface AFArrayView ()
{
	@private __strong AFKVO *_kvo;
}


@end // @interface AFArrayView ()


#pragma mark - Class Definition

// THIS CLASS IS NOT THREAD-SAFE
@implementation AFArrayView


#pragma mark - Properties

- (void)setFilter: (AFArrayViewFilter)filter
{
	_filter = [filter copy];
	
	// Refresh objects.
	[self _refreshObjects];
}

- (void)setComparator: (AFArrayViewComparator)comparator
{
	_comparator = [comparator copy];
	
	// Refresh objects.
	[self _refreshObjects];
}

- (void)setSortOrder: (AFArrayViewSortOrder)sortOrder
{
	// TODO: Implement this.
	_sortOrder = sortOrder;
	
	// Refresh objects.
	[self _refreshObjects];
}

- (void)setObjects: (NSArray *)objects
{
	// NOTE: copy properties will copy objects as immutable.
	_objects = [objects mutableCopy];
}

- (void)setSource: (AFArray *)source
{
	// Remove KVO.
	if (_source != nil)
	{
		[_kvo stopObserving: _source
			forKeyPath: AFArray_ObjectsKeyPath];
	}

	// Set value.
	_source = source;
	
	// Add KVO.
	if (_source != nil)
	{
		[_kvo startObserving: _source
			forKeyPath: AFArray_ObjectsKeyPath
			options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
			selector: @selector(_sourceDidChange:)];
	}
}


#pragma mark - Constructors

- (id)initWithSource: (AFArray *)source
	comparator: (AFArrayViewComparator)comparator
	filter: (AFArrayViewFilter)filter
	sortOrder: (AFArrayViewSortOrder)sortOrder
{
	// Abort if base initializer fails.
	if ((self = [self initWithSource: source]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_comparator = [comparator copy];
	_filter = [filter copy];
	_sortOrder = sortOrder;
	
	// Refresh the objects.
	[self _refreshObjects];
	
	// Return initialized instance.
	return self;
}

- (id)initWithSource: (AFArray *)source
{
	// Abort if base initializer fails.
	if ((self = [self init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_source = source;
	
	// Refresh the objects.
	[self _refreshObjects];
	
	// Return initialized instance.
	return self;
}

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_kvo = [[AFKVO alloc]
		initWithTarget: self];
	
	// Return initialized instance.
	return self;
}

+ (AFArrayView *)arrayViewWithSource: (AFArray *)source
	comparator: (AFArrayViewComparator)comparator
	filter: (AFArrayViewFilter)filter
	sortOrder: (AFArrayViewSortOrder)sortOrder
{
	return [[AFArrayView alloc]
		initWithSource: source
		comparator: comparator
		filter: filter
		sortOrder: sortOrder];
}

+ (AFArrayView *)arrayViewWithSource: (AFArray *)source
{
	return [[AFArrayView alloc]
		initWithSource: source];
}

+ (AFArrayView *)arrayView
{
	return [[AFArrayView alloc]
		init];
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

- (void)refresh
{
	// Refresh objects.
	[self _refreshObjects];
}


#pragma mark - Private Methods

- (void)_sourceDidChange: (NSDictionary *)change
{
	BOOL isPrior = [[change objectForKey: NSKeyValueChangeNotificationIsPriorKey]
		boolValue];
	NSKeyValueChange changeKind = [[change objectForKey: NSKeyValueChangeKindKey]
		intValue];
		
	switch (changeKind)
	{
		// NOTE: This class will never generate replacement changes.
		case NSKeyValueChangeSetting:
		case NSKeyValueChangeReplacement:
		{
			if (isPrior == NO)
			{
				// Refresh the objects.
				[self _refreshObjects];
			}
			
			break;
		}
		
		case NSKeyValueChangeInsertion:
		{
			NSIndexSet *indices = [change objectForKey: NSKeyValueChangeIndexesKey];
			
			if (isPrior == NO)
			{
				NSMutableArray *objectsToInsert = [[NSMutableArray alloc]
					init];
				NSMutableIndexSet *indicesToInsert = [[NSMutableIndexSet alloc]
					init];

				// Enumerate each inserted index.
				[indices enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL *stop) 
					{
						id object = [_source objectInObjectsAtIndex: index];
						
						if (_filter == nil
							|| _filter(object) == YES)
						{
							// Insert this object in the sorted, filtered array.
							NSUInteger index = [self _sortedIndexForInsertingObject: object
								inArray: _objects];
							[objectsToInsert addObject: object];
							[indicesToInsert addIndex: index];
						}
					}];
				
				// Insert objects at their sorted locations.
				[self insertObjects: objectsToInsert
					atIndexes: indicesToInsert];
			}

			break;
		}
		case NSKeyValueChangeRemoval:
		{
			NSIndexSet *indices = [change  objectForKey: NSKeyValueChangeIndexesKey];
				
			if (isPrior == YES)
			{
				NSMutableIndexSet *indicesToRemove = [[NSMutableIndexSet alloc]
					init];
			
				// Build list of indices to remove.
				[indices enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL *stop) 
					{
						id object = [_source.objects objectAtIndex: index];
						
						if ([_objects containsObject: object] == YES)
						{
							NSUInteger index = [_objects indexOfObject: object];
							[indicesToRemove addIndex: index];
						}
					}];
				
				// Remove objects.
				[self removeObjectsAtIndexes: indices];
			}

			break;
		}
	}
}

- (void)_refreshObjects
{
	NSMutableArray *objects = nil;

	// Filter the objects, if a filter is provided.
	if (_filter != nil)
	{
		objects = [NSMutableArray array];
		
		for (id object in _source.objects)
		{
			// If the filter marks the object for inclusion, include it.
			if (_filter(object) == YES)
			{
				[objects addObject: object];
			}
		}
	}
	
	// If no filter is provided, use all of the source objects.
	else
	{
		objects = [_source.objects mutableCopy];
	}
	
	// Assign the updated objects.
	self.objects = objects;
}

- (NSUInteger)_sortedIndexForInsertingObject: (id)object
	inArray: (NSArray *)array
{
	NSUInteger index = 0;
	NSUInteger topIndex = [array count];
	IMP objectAtIndexImp = [array methodForSelector: @selector(objectAtIndex:)];
	while (index < topIndex) 
	{
		NSUInteger midIndex = (index + topIndex) / 2;
		id testObject = objectAtIndexImp(array, @selector(objectAtIndex:), midIndex);
		if (_comparator == nil || _comparator(object, testObject) > 0)
		{
			index = midIndex + 1;
		}
		else 
		{
			topIndex = midIndex;
		}
	}
	return index;
}


@end // @implementation AFArrayView