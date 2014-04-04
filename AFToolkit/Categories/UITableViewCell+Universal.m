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

+ (instancetype)universalCell
{
	return [self cellWithUniversalNibName: self.universalNibName];
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

- (CGFloat)heightConstrainedToWidth: (CGFloat)width
	useAutoLayout: (BOOL)useAutoLayout
{
	// Update the constraints.
	[self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
	
	// Set the bounds.
	self.bounds = CGRectMake(0.0f, 0.0f, width, CGRectGetHeight(self.bounds));
	
	// Update the layout.
	[self setNeedsLayout];
    [self layoutIfNeeded];
	
	// If the cell supports AutoLayout, use systemLayoutSizeFittingSize.
	if (useAutoLayout == NO)
	{
		CGFloat height = 0.f;
	
		// Size to the cell's subviews.
		for (UIView *subview in self.contentView.subviews)
		{
			if (subview.frame.origin.y + subview.frame.size.height > height)
			{
				height = subview.frame.origin.y + subview.frame.size.height;
			}
		}
		
		return height;
	}
	else
	{
		// Get the height.
		CGFloat height = [self.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize].height;

		// Add an extra point to the height to account for the cell separator, which is added between the bottom
		// of the cell's contentView and the bottom of the table view cell.
		height += 1.0f;
		
		// Return the height.
		return height;
	}
}


@end