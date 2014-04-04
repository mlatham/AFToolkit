

#pragma mark Class Interface

@interface UITableViewCell (Universal)


#pragma mark - Instance Methods

// Returns this cell's class name.

+ (NSString *)universalNibName;

+ (instancetype)cellWithUniversalNibName: (NSString *)nibName;

+ (instancetype)cellWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil;

// Gets a singleton instance of this cell type, useable for layout and sizing.

+ (instancetype)templateCell;

// Lays out this cell's subviews and returns the height that fits the provided width.

- (CGFloat)heightConstrainedToWidth: (CGFloat)width;


@end