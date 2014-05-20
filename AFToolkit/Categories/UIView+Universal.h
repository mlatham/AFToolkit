#import "UIKit/UIKit.h"


#pragma mark Class Interface

@interface UIView (Universal)


#pragma mark - Instance Methods

+ (instancetype)viewWithUniversalNibName: (NSString *)nibName
	owner: (id)owner;
	
+ (instancetype)viewWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil
	owner: (id)owner;

+ (NSArray *)viewsWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil
	owner: (id)owner;


@end