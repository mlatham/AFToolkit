#import "AFView.h"
#import "AFPlatformHelper.h"
#import "UIView+Universal.h"


#pragma mark Class Definition

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

- (id)initWithFrame: (CGRect)frame
	universalNibName: (NSString *)nibName
{
	// Load the composite view.
	if ((self = [super initWithFrame: frame]) == nil)
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
	// Load the universal nib for the view.
	UIView *view = [UIView viewWithUniversalNibName: nibName
		bundle: nibBundleOrNil
		owner: self];
	
	// Always transfer the view's background color.
	self.backgroundColor = view.backgroundColor;
	
	// Align the nib view's frame with the container view's frame.
	view.frame = self.bounds;
	
	// Add the nib view as a child of this view.
	[self addSubview: view];
}


@end