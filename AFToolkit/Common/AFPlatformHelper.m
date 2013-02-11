#import "AFPlatformHelper.h"
#include <sys/types.h>
#include <sys/sysctl.h>


#pragma mark Private Methods

@interface AFPlatformHelper ()

@end  // @interface AFPlatformHelper ()


#pragma mark - Class Variables

static BOOL _classInitialized;
static NSString *_OSVersion = nil;
static HardwareFamily _hardwareFamily = HardwareFamilyUnknown;
static HardwareGeneration _hardwareGeneration = 0;
static Platform _platform = PlatformiPhone;
static NSString * _platformName = nil;
static CGFloat _keyboardHeightPortrait = 0.f;
static CGFloat _keyboardHeightLandscape = 0.f;


#pragma mark - Class Definition

@implementation AFPlatformHelper


#pragma mark - Constructors

+ (void)initialize
{
	if (_classInitialized == NO)
	{
		_classInitialized = YES;
    
		// get os version
		_OSVersion = [[UIDevice currentDevice].systemVersion
			copy];
			
		// get hardware string
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = (char *)malloc(size);
		sysctlbyname("hw.machine", machine, &size, NULL, 0);
		NSString *hardware = [NSString stringWithCString: machine
			encoding: NSASCIIStringEncoding];
		free(machine);
		
		// parse family from hardware
		if ([hardware rangeOfString: @"iPhone" 
			options: NSAnchoredSearch].location == 0)
		{
			_hardwareFamily = HardwareFamilyiPhone;
		}
		else if ([hardware rangeOfString: @"iPad" 
			options: NSAnchoredSearch].location == 0)
		{
			_hardwareFamily = HardwareFamilyiPad;
		}
		else if ([hardware rangeOfString: @"iPod" 
			options: NSAnchoredSearch].location == 0)
		{
			_hardwareFamily = HardwareFamilyiPod;
		}
		else if ([hardware rangeOfString: @"i386" 
				options: NSAnchoredSearch].location == 0
			|| [hardware rangeOfString: @"x86" 
				options: NSAnchoredSearch].location == 0)
		{
			_hardwareFamily = HardwareFamilySimulator;
		}
		else
		{
			_hardwareFamily = HardwareFamilyUnknown;
		}
		
		// parse generation (if not simulator)
		if (_hardwareFamily != HardwareFamilySimulator
			&& _hardwareFamily != HardwareFamilyUnknown)
		{
			// create scanner
			NSScanner *scanner = [NSScanner scannerWithString: hardware];
			NSCharacterSet *numericCharacters = 
				[NSCharacterSet decimalDigitCharacterSet];
				
			// scan past non numerics
			[scanner scanUpToCharactersFromSet: numericCharacters 
				intoString: NULL];
				
			// scan generation
			int generation;
			if ([scanner scanInt: &generation] == YES)
			{
				_hardwareGeneration = generation;
			}
		}
		
		// initialize for iPad
		UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] 
			userInterfaceIdiom];
		if (idiom == UIUserInterfaceIdiomPad)
		{
			_platform = PlatformiPad;
			_platformName = @"iPad";
			_keyboardHeightPortrait = 264.f;
			_keyboardHeightLandscape = 352.f;
		}
		
		// or initialize iPhone
		else
		{
			_platform = PlatformiPhone;
			_platformName = @"iPhone";
			_keyboardHeightPortrait = 216.f;
			_keyboardHeightLandscape = 162.f;
		}
	}
}


#pragma mark - Public Methods

+ (Orientation)orientation
{
    // use interface orientation (if possible)
    UIWindow *mainWindow = [[UIApplication sharedApplication]
        keyWindow];
    if (mainWindow != nil
        && mainWindow.rootViewController != nil)
    {
        UIInterfaceOrientation interfaceOrientation = 
            [mainWindow rootViewController].interfaceOrientation;
        return interfaceOrientation == 
            UIInterfaceOrientationIsPortrait(interfaceOrientation)
                ? OrientationPortrait : OrientationLandscape;
    }

    // fallback to device value (if known)
	UIDeviceOrientation orientation = [[UIDevice currentDevice] 
        orientation];	
    if (orientation == UIDeviceOrientationUnknown)
    {
        return OrientationPortrait;
    }
        
	if (UIDeviceOrientationIsLandscape(orientation))
    {
        return OrientationLandscape;
    }
    else 
    {
        return OrientationPortrait;
    }
}

+ (NSString *)OSVersion
{
	return _OSVersion;
}

+ (HardwareFamily)hardwareFamily
{
	return _hardwareFamily;
}

+ (HardwareGeneration)hardwareGeneration
{
	return _hardwareGeneration;
}
     
+ (NSString *)platformName
{
	return _platformName;
}

+ (Platform)platform
{
	return _platform;
}

+ (CGFloat)contentWidth
{
	UIScreen *mainScreen = [UIScreen mainScreen];
	return mainScreen.applicationFrame.size.width;
}

+ (CGFloat)contentHeight
{
	UIScreen *mainScreen = [UIScreen mainScreen];
	return mainScreen.applicationFrame.size.height;
}

+ (CGFloat)keyboardHeight
{
	return self.orientation == OrientationLandscape
		? _keyboardHeightLandscape
		: _keyboardHeightPortrait;
}

+ (CGFloat)keyboardHeightForOrientation: (Orientation)orientation
{
	return orientation == OrientationLandscape
		? _keyboardHeightLandscape
		: _keyboardHeightPortrait;
}

+ (CGFloat)contentHeightForOrientation: (Orientation)orientation
{
	Orientation screenOrientation = self.orientation;
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	return orientation != screenOrientation
		? mainScreen.applicationFrame.size.width
		: mainScreen.applicationFrame.size.height;
}

+ (CGFloat)contentWidthForOrientation: (Orientation)orientation
{
	Orientation screenOrientation = self.orientation;
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	return orientation != screenOrientation
		? mainScreen.applicationFrame.size.height
		: mainScreen.applicationFrame.size.width;
}


@end // @implementation AFPlatformHelper