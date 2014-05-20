#import "Foundation/Foundation.h"
#import "SystemConfiguration/SystemConfiguration.h"


#pragma mark Enumerations

typedef enum
{
	AFReachabilityStateUnknown = 0,
    AFReachabilityStateOffline,
    AFReachabilityStateOnline
	
} AFReachabilityState;


#pragma mark - Constants

extern NSString * const AFReachability_StateKeyPath;


#pragma mark - Class Interface

@interface AFReachability : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) AFReachabilityState state;


#pragma mark - Static Methods

+ (AFReachability *)reachabilityWithHostName: (NSString *)hostName; 
+ (AFReachability *)reachabilityForInternetConnection;


#pragma mark - Instance Methods

- (BOOL)start;
- (void)stop;


@end