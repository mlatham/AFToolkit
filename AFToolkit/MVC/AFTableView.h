#import "AFArray.h"


#pragma mark Class Interface

@interface AFTableView : UITableView


#pragma mark - Properties

// TODO: Implement a table view model.
@property (nonatomic, strong) AFArray *itemsSource;

@property (nonatomic, assign) UIViewContentMode emptyViewContentMode;
@property (nonatomic, assign) BOOL emptyViewHidden;
@property (nonatomic, strong) UIView *emptyView;


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
	style: (UITableViewStyle)style;


#pragma mark - Instance Methods

- (id)dequeueReusableCellWithUniversalNibName: (NSString *)universalNibName;
- (id)dequeueReusableHeaderFooterViewWithUniversalNibName: (NSString *)universalNibName;

- (void)setEmptyViewHidden: (BOOL)emptyViewHidden
	animated: (BOOL)animated
	completion: (void (^)(BOOL success))completion;


@end // @interface AFTableView