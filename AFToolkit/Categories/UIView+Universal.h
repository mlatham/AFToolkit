#import <UIKit/UIKit.h>


#pragma mark Class Interface

@interface UIView (Universal)


#pragma mark - Instance Methods

+ (UIView *)viewWithUniversalNibName: (NSString *)nibName;
+ (UIView *)viewWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil;


@end // @interface UIView (Universal)