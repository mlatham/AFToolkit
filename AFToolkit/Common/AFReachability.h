#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


#pragma mark Enumerations

typedef enum
{
    AFReachabilityStateOffline = 0,
    AFReachabilityStateWiFi,
    AFReachabilityStateWWAN
} AFReachabilityState;


#pragma mark - Class Interface

@interface AFReachability : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) AFReachabilityState state;


#pragma mark - Static Methods

+ (AFReachability *)connectivityWithHostName: (NSString *)hostName; 
+ (AFReachability *)reachabilityWithAddress: (const struct sockaddr_in *) hostAddress;
+ (AFReachability *)reachabilityForInternetConnection;
+ (AFReachability *)reachabilityForLocalWiFi;


#pragma mark - Instance Methods

- (BOOL)start;
- (void)stop;


@end