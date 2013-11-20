#import "UIView+Universal.h"
#import "NSBundle+Universal.h"


#pragma mark Class Definition

@implementation UIView (Universal)


#pragma mark - Public Methods

+ (instancetype)viewWithUniversalNibName: (NSString *)nibName
	owner: (id)owner
{
	return [self viewWithUniversalNibName: nibName
		bundle: nil
		owner: owner];
}

+ (instancetype)viewWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil
	owner: (id)owner
{
	// Load all views in the nib.
	NSArray *nibViews = [self viewsWithUniversalNibName: nibName
		bundle: nibBundleOrNil
		owner: owner];
	
	// Validate that the nib contains a view.
	AFAssert(nibViews.count == 1);
	
	// Return first object in nib.
	id nibRoot = nibViews[0];
	
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

+ (NSArray *)viewsWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil
	owner: (id)owner
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
	
	// Load the nib, with this view as it's owner.
	NSArray *nibContents = [bundle loadNibNamed: deviceNibName 
		owner: owner
		options: nil];

	NSMutableArray *views = [NSMutableArray array];

	// Find each view in the nib.
	for (id object in nibContents)
	{
		if ([object isKindOfClass: UIView.class])
		{
			[views addObject: object];
		}
	}
	
	// Return the views.
	return views;
}


@end