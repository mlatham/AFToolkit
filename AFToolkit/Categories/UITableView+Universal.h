@import UIKit;


#pragma mark Class Interface

@interface UITableView (Universal)


#pragma mark - Instance Methods

- (id)dequeueReusableCellWithCellClass: (Class)cellClass;

- (id)dequeueReusableCellWithUniversalNibName: (NSString *)universalNibName;

- (id)dequeueReusableHeaderFooterViewWithUniversalNibName: (NSString *)universalNibName;


@end