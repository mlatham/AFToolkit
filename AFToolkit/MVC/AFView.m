#import "AFView.h"
#import "AFPlatformHelper.h"
#import "NSBundle+Universal.h"


#pragma mark Constants


#pragma mark - Class Extensions

@interface AFView ()

- (void)AF_loadViewWithUniversalNibName: (NSString *)nibName
	bundle: (NSBundle *)nibBundleOrNil;
	

@end // @interface AFView ()


#pragma mark - Class Definition

@implementation AFView


#pragma mark - Constructors

- (id)initWithCoder: (NSCoder *)coder
	universalNibName: (NSString *)nibName
{
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Load the composite view.
	[self AF_loadViewWithUniversalNibName: nibName 
		bundle: nil];
        
	return self;
}

- (id)initWithUniversalNibName: (NSString *)nibName
{
	if ((self = [super initWithFrame: CGRectZero]) == nil)
	{
		return nil;
	}
	
	// Load the composite view.
	[self AF_loadViewWithUniversalNibName: nibName 
		bundle: nil];
	
	return self;
}


#pragma mark - Overridden Methods

+ (id)alloc
{
	// Resolve platform-specific class (if any).
	NSString *platformClassName = [[NSString alloc] 
		initWithFormat: @"%@_%@", NSStringFromClass(self), 
		[AFPlatformHelper platformName]];
	Class deviceClass = NSClassFromString(platformClassName);
    
    // Fallback to platform-neutral class.
	if (deviceClass != nil)
	{
		return [deviceClass alloc];
	}
	return [super alloc];
}

+ (id)allocWithZone: (NSZone *)zone
{
	// Resolve platform-specific class (if any).
	NSString *platformClassName = [[NSString alloc] 
		initWithFormat: @"%@_%@", NSStringFromClass(self), 
		[AFPlatformHelper platformName]];
	Class deviceClass = NSClassFromString(platformClassName);
    
    // Fallback to platform-neutral class.
	if (deviceClass != nil)
	{
		return [deviceClass allocWithZone: zone];
	}
	return [super allocWithZone: zone];
}


#pragma mark - Private Methods

- (void)AF_loadViewWithUniversalNibName: (NSString *)nibName
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
	
	// Load the nib, with this view as it's owner.
	NSArray *nibContents = [bundle loadNibNamed: deviceNibName 
		owner: self 
		options: nil];
		
	// Validate that the nib contains a view.
	AFAssert(nibContents.count == 1 
		&& [[nibContents objectAtIndex: 0] class] == [UIView class]);

	// Get the decoded view.
	UIView *view = [nibContents objectAtIndex: 0];

	// Add the view as a subview of this view.
	[self addSubview: view];
	
	// Ensure this container view has a clear background color.
	self.backgroundColor = [UIColor clearColor];
	
	// Align the view's autoresize mask with this view.
	self.autoresizingMask = view.autoresizingMask;
	
	// Always transfer this view's width and height values to the subview.
	CGRect frame = view.frame;
	frame.size.width = view.frame.size.width;
	frame.size.height = view.frame.size.height;
	self.frame = frame;
}


@end  // @implementation AFView