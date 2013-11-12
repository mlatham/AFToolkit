#import "AFArray.h"


#pragma mark Class Interface

@interface AFTableView : UITableView


#pragma mark - Properties

// TODO: Implement a table view model.
@property (nonatomic, strong) AFArray *itemsSource;

@property (nonatomic, assign) BOOL scrollableBackgroundViewHidden;
@property (nonatomic, strong) UIView *scrollableBackgroundView;


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
	style: (UITableViewStyle)style;


@end