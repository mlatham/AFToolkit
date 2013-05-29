#import "UITableView+Universal.h"
#import "UITableViewCell+Universal.h"
#import "UIView+Universal.h"


#pragma mark Class Definition

@implementation UITableView (Universal)


#pragma mark - Public Methods

- (id)dequeueReusableCellWithUniversalNibName: (NSString *)universalNibName
{
	// Reuse cell if possible (or create one).
	UITableViewCell *cell = [self dequeueReusableCellWithIdentifier: universalNibName];
	if (cell == nil)
	{
		cell = [UITableViewCell cellWithUniversalNibName: universalNibName];
	}
	
	// Return cell.
	return cell;
}

- (id)dequeueReusableHeaderFooterViewWithUniversalNibName: (NSString *)universalNibName
{
	// Reuse view if possible (or create one).
	UIView *view = [self dequeueReusableHeaderFooterViewWithIdentifier: universalNibName];
	if (view == nil)
	{
		view = [UIView viewWithUniversalNibName: universalNibName];
	}
	
	// Return view.
	return view;
}


@end // @implementation UITableView (Universal)