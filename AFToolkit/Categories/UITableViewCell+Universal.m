#import "UITableViewCell+Universal.h"
#import "NSBundle+Universal.h"
#import <objc/runtime.h>


#pragma mark Constants

// Use the addresses as the key.
static char TEMPLATE_KEY;


#pragma mark - Class Definition

@implementation UITableViewCell (Universal)

+ (NSString *)universalNibName
{
	return NSStringFromClass([self class]);
}

+ (instancetype)cellWithUniversalNibName: (NSString *)nibName
{
	return [self cellWithUniversalNibName: nibName
		bundle: nil];
}

+ (instancetype)cellWithUniversalNibName: (NSString *)nibName
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
	
	// Return first object in nib.
	id nibRoot = [nibContents objectAtIndex: 0];
	
	// Validate nib contained a cell.
	AFAssert([nibRoot isKindOfClass: UITableViewCell.class]);
	
	return nibRoot;
}

+ (instancetype)templateCell
{
	id instance = (id)objc_getAssociatedObject(self, &TEMPLATE_KEY);
	
	// Create the template on demand.
	if (instance == nil)
	{
		instance = [self cellWithUniversalNibName: self.universalNibName];
	
		objc_setAssociatedObject(self, &TEMPLATE_KEY, instance, OBJC_ASSOCIATION_RETAIN);
	}
	
	return instance;
}


@end