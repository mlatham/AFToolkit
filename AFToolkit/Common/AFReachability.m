#import "AFReachability.h"
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>


#pragma mark Class Extension

@interface AFReachability ()
{
	@private BOOL _localWiFiRef;
    @private SCNetworkReachabilityRef _reachabilityRef;
}

@end // @interface AFReachability ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation AFReachability


#pragma mark - Class Methods

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
}


#pragma mark - Properties

- (AFReachabilityState)state
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL _reachabilityRef");
	
    AFReachabilityState result = AFReachabilityStateOffline;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        if(_localWiFiRef)
        {
            result = [self localWiFiStatusForFlags: flags];
        }
        else
        {
            result = [self networkStatusForFlags: flags];
        }
    }
	
    return result;
}


#pragma mark - Constructors
 
- (BOOL)start
{
    BOOL result = NO;
	
    SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
    if(SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
    {
        if(SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            result = YES;
        }
    }
	
    return result;
}
 
- (void)stop
{
    if(_reachabilityRef!= NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

+ (AFReachability *)reachabilityWithHostName: (NSString *)hostName;
{
    AFReachability *result = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if(reachability != NULL)
    {
        result = [[self alloc]
			init];
        if(result != NULL)
        {
            result->_reachabilityRef = reachability;
            result->_localWiFiRef = NO;
        }
    }
	
    return result;
}
 
+ (AFReachability *)reachabilityWithAddress: (const struct sockaddr_in *)hostAddress;
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    AFReachability *result = NULL;
    if(reachability!= NULL)
    {
        result = [[self alloc]
			init];
        if(result != NULL)
        {
            result->_reachabilityRef = reachability;
            result->_localWiFiRef = NO;
        }
    }
	
    return result;
}
 
+ (AFReachability *)reachabilityForInternetConnection;
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    return [self reachabilityWithAddress: &zeroAddress];
}
 
+ (AFReachability *)reachabilityForLocalWiFi;
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
	
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    AFReachability *result = [self reachabilityWithAddress: &localWifiAddress];
    if(result!= NULL)
    {
        result->_localWiFiRef = YES;
    }
	
    return result;
}

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	
	// Return initialized instance.
	return self;
}


#pragma mark - Destructors

- (void) dealloc
{
    [self stop];
    
	if(_reachabilityRef!= NULL)
    {
        CFRelease(_reachabilityRef);
    }
}


#pragma mark - Private Methods

- (AFReachabilityState)localWiFiStatusForFlags: (SCNetworkReachabilityFlags)flags
{
    BOOL result = AFReachabilityStateOffline;
	
    if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
    {
        result = AFReachabilityStateWiFi;
    }
	
    return result;
}
 
- (AFReachabilityState)networkStatusForFlags: (SCNetworkReachabilityFlags)flags
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // If target host is not reachable.
        return AFReachabilityStateOffline;
    }
 
    BOOL result = AFReachabilityStateOffline;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // If target host is reachable and no connection is required
        // then we'll assume (for now) that your on Wi-Fi.
        result = AFReachabilityStateWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
		// The connection is on-demand (or on-traffic) if the
		// calling application is using the CFSocketStream or higher APIs

		if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
		{
			// No [user] intervention is needed
			result = AFReachabilityStateWiFi;
		}
	}
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // WWAN connections are OK if the calling application
        // is using the CFNetwork (CFSocketStream?) APIs.
        result = AFReachabilityStateWWAN;
    }
	
    return result;
}
 
- (BOOL)connectionRequired;
{
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL _reachabilityRef");
	
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
	
    return NO;
}


@end // @implementation AFReachability