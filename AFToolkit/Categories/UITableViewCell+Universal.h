

#pragma mark Class Interface

@interface UITableViewCell (Universal)


#pragma mark - Instance Methods

+ (instancetype)cellWithUniversalNibName: (NSString *)nibName;

+ (instancetype)cellWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil;


@end