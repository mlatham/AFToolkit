#import "UIView+Universal.h"
#import "NSBundle+Universal.h"


#pragma mark Class Definition

@implementation UIView (Universal)


#pragma mark - Public Methods

+ (UIView *)viewWithUniversalNibName: (NSString *)nibName
{
	return [self viewWithUniversalNibName: nibName
		bundle: nil];
}

+ (UIView *)viewWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil
{
	// This method allows resolution of nib names according to certain
	// naming conventions. nibs are resolved using naming in the following order:
	// 1) nibName_platformName (eg: MyView_iPhone)
	// 2) nibName (eg: MyView)
	// 3) nibName_iPhone (eg: MyView_iPhone)
	// the purpose of 3) is to account for iPhone-only nibs being run on an iPad.

	NSBundle *bundle = nibBundleOrNil == nil 
		? [NSBundle mainBundle] 
		: nibBundleOrNil;
	
	// Resolve platform-specific nib name.
	NSString *deviceNibName = [bundle universalNibNameForNibName: nibName];

	NSArray *nibContents = [[NSBundle mainBundle] 
		loadNibNamed: deviceNibName 
		owner: self 
		options: nil];
	
	// Validate that the nib contains a view.
	AFAssert(nibContents.count == 1 
		&& [[nibContents objectAtIndex: 0] class] == [UIView class]);
	
	// Return first object in nib.
	id nibRoot = [nibContents objectAtIndex: 0];
	
	// Call viewDidLoad, if defined.
	SEL selector = @selector(viewDidLoad);
	if ([nibRoot respondsToSelector: selector])
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[nibRoot performSelector: selector];
#pragma clang diagnostic pop
	}
	
	return nibRoot;
}


@end // @implementation UIView (Universal)