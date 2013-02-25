#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


#pragma mark Enumerations

typedef enum
{
    AFReachabilityStateOffline = 0,
    AFReachabilityStateOnline
	
} AFReachabilityState;


#pragma mark - Class Interface

@interface AFReachability : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) AFReachabilityState state;


#pragma mark - Static Methods

+ (AFReachability *)connectivityWithHostName: (NSString *)hostName; 
+ (AFReachability *)reachabilityForInternetConnection;


#pragma mark - Instance Methods

- (BOOL)start;
- (void)stop;


@end