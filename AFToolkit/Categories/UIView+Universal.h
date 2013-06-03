#import <UIKit/UIKit.h>


#pragma mark Class Interface

@interface UIView (Universal)


#pragma mark - Instance Methods

+ (UIView *)viewWithUniversalNibName: (NSString *)nibName
	owner: (id)owner;
+ (UIView *)viewWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil
	owner: (id)owner;


@end // @interface UIView (Universal)