#import "UIColor+Hex.h"


#pragma mark Class Definition

@implementation UIColor (Hex)


#pragma mark - Public Methods

+ (UIColor *)colorWithHex: (int)hexValue
{
	return [[UIColor alloc]
		initWithRed: ((float)((hexValue & 0xFF0000) >> 16)) / 255.f 
		green: ((float)((hexValue & 0xFF00) >> 8)) / 255.f 
		blue: ((float)(hexValue & 0xFF)) / 255.f 
		alpha: 1.f];
}

+ (UIColor *)colorWithHex: (int)hexValue
	alpha: (float)alpha
{
	return [[UIColor alloc]
		initWithRed: ((float)((hexValue & 0xFF0000) >> 16)) / 255.f 
		green: ((float)((hexValue & 0xFF00) >> 8)) / 255.f 
		blue: ((float)(hexValue & 0xFF)) / 255.f 
		alpha: alpha];
}


@end // @implementation UIColor (Hex)