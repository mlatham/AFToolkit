#import "AFViewController.h"
#import "AFPlatformHelper.h"
#import "NSBundle+Universal.h"


#pragma mark - Class Extension

@interface AFViewController ()
{
	@private BOOL _visible;
}


@end  // @interface AFViewController ()


#pragma mark - Class Definition

@implementation AFViewController


#pragma mark - Properties


#pragma mark - Constructors

- (id)initWithUniversalNibName: (NSString *)nibName
{
	// this method allows resolution of nib names according to certain
	// naming conventions. nibs are resolved using naming in the following order:
	// 1) nibName_platformName (eg: MyView_iPhone)
	// 2) nibName (eg: MyView)
	// 3) nibName_iPhone (eg: MyView_iPhone)
	// the purpose of 3) is to account for iPhone-only nibs being run on an iPad.
	
	NSBundle *bundle = [NSBundle mainBundle];

	// resolve platform-specific nib name
	NSString *deviceNibName = [bundle universalNibNameForNibName: nibName];

    // ensure nib can be allocated
	if ((self = [super initWithNibName: deviceNibName
		bundle: bundle]) == nil)
	{
		return nil;
    }
	
    return self;
}


#pragma mark - Overridden Methods

+ (id)alloc
{
	// resolve platform-specific class (if any)
	NSString *platformClassName = [[NSString alloc] 
		initWithFormat: @"%@_%@", NSStringFromClass(self), 
		[AFPlatformHelper platformName]];
	Class deviceClass = NSClassFromString(platformClassName);
    
    // fallback to platform-neutral class
	if (deviceClass != nil)
	{
		return [deviceClass alloc];
	}
	return [super alloc];
}

+ (id)allocWithZone: (NSZone *)zone
{
	// resolve platform-specific class (if any)
	NSString *platformClassName = [[NSString alloc] 
		initWithFormat: @"%@_%@", NSStringFromClass(self), 
		[AFPlatformHelper platformName]];
	Class deviceClass = NSClassFromString(platformClassName);
    
    // fallback to platform-neutral class
	if (deviceClass != nil)
	{
		return [deviceClass allocWithZone: zone];
	}
	return [super allocWithZone: zone];
}

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// track visibility
	_visible = YES;
}

- (void)viewDidDisappear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidDisappear: animated];
	
	// track visibility
	_visible = NO;
}


@end  // @interface AFViewController