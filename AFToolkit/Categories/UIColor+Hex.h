#import <UIKit/UIKit.h>


#pragma mark Class Interface

@interface UIColor (Hex)


#pragma mark - Instance Methods

+ (UIColor *)colorWithHex: (int)hexValue;
+ (UIColor *)colorWithHex: (int)hexValue
	alpha: (float)alpha;

@end // @interface UIColor (Hex)