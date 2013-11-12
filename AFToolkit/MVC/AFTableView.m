#import "AFTableView.h"
#import "UITableViewCell+Universal.h"
#import "UIView+Universal.h"
#import "AFKeypath.h"
#import "AFKVO.h"


#pragma mark Class Definition

@implementation AFTableView
{
	@private __strong AFKVO *_kvo;
}

#pragma mark - Properties

- (void)setItemsSource: (AFArray *)itemsSource
{
	// Remove KVO.
	if (_itemsSource != nil)
	{
		[_kvo stopObserving: _itemsSource
			forKeyPath: @keypath(itemsSource.objects)];
	}
	
	// Set value.
	_itemsSource = itemsSource;
	
	// Add KVO.
	if (_itemsSource != nil)
	{
		[_kvo startObserving: _itemsSource
			forKeyPath: @keypath(itemsSource.objects)
			selector: @selector(_sourceDidChange:)];
	}
}


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
	style: (UITableViewStyle)style
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame
		style: style]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeTableView];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Private Methods

- (void)_initializeTableView
{
	// Initialize instance variables.
}

- (void)_sourceDidChange: (NSDictionary *)change
{
	// Respond to change.
	NSKeyValueChange changeKind = [[change objectForKey: NSKeyValueChangeKindKey]
		intValue];
	
	switch (changeKind)
	{
		case NSKeyValueChangeSetting:
		case NSKeyValueChangeReplacement:
        {
            // Reload the data.
			[self reloadData];
            break;
		}
		case NSKeyValueChangeRemoval:
		{
			// Remove deleted objects.
			NSIndexSet *indexSet = [change objectForKey: NSKeyValueChangeIndexesKey];
			[self _removeIndexSet: indexSet];
			break;
		}
		case NSKeyValueChangeInsertion:
		{
			// Remove deleted objects.
			NSIndexSet *indexSet = [change objectForKey: NSKeyValueChangeIndexesKey];
			[self _insertIndexSet: indexSet];
			break;
		}
		default:
			break;
	}
}

- (void)_removeIndexSet: (NSIndexSet *)indicesSet
{
    NSInteger firstIndex = indicesSet.firstIndex;
    NSInteger lastIndex = indicesSet.lastIndex;

	// Only insert if there are additions.
	if ([indicesSet count] <= 0)
	{
		return;
	}

	// Begin updates.
    [self beginUpdates];
    
    NSMutableArray *indicesRemoved = [NSMutableArray array];
    for (int i = firstIndex; i <= lastIndex; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: i
			inSection: 0];
        [indicesRemoved addObject: indexPath];
    }
    
    [self deleteRowsAtIndexPaths: indicesRemoved
        withRowAnimation: UITableViewRowAnimationAutomatic];
		
	// End updates.
    [self endUpdates];
}

- (void)_insertIndexSet: (NSIndexSet *)indicesSet
{
    NSInteger firstIndex = indicesSet.firstIndex;
    NSInteger lastIndex = indicesSet.lastIndex;
	
	// Only insert if there are additions.
	if ([indicesSet count] <= 0)
	{
		return;
	}

	// Begin updates.
    [self beginUpdates];
    
    NSMutableArray *indicesAdded = [NSMutableArray array];
    for (int i = firstIndex; i <= lastIndex; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: i
			inSection: 0];
        [indicesAdded addObject: indexPath];
    }
    
    [self insertRowsAtIndexPaths: indicesAdded
        withRowAnimation: UITableViewRowAnimationAutomatic];
		
	// End updates.
    [self endUpdates];
}


@end