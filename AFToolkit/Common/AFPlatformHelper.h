@import UIKit;


#pragma mark Typedefs

typedef NSUInteger HardwareGeneration;


#pragma mark - Enumerations

typedef enum
{
	HardwareFamilyUnknown,
	HardwareFamilyiPod,
	HardwareFamilyiPhone,
	HardwareFamilyiPad,
	HardwareFamilySimulator
} HardwareFamily;

typedef enum 
{
	PlatformiPhone = 0,
	PlatformiPad = 1

} Platform;

typedef enum 
{
	OrientationPortrait = 0,
	OrientationLandscape = 1

} Orientation;


#pragma mark - Class Interface

@interface AFPlatformHelper : NSObject


#pragma mark - Methods

+ (Orientation)orientation; 
    
+ (NSString *)OSVersion;
+ (HardwareFamily)hardwareFamily;
+ (HardwareGeneration)hardwareGeneration;
        
+ (NSString *)platformName;
+ (Platform)platform;

+ (CGFloat)contentWidth;
+ (CGFloat)contentHeight;
+ (CGFloat)keyboardHeight;

+ (CGFloat)keyboardHeightForOrientation: (Orientation)orientation;
+ (CGFloat)contentHeightForOrientation: (Orientation)orientation;
+ (CGFloat)contentWidthForOrientation: (Orientation)orientation;


@end