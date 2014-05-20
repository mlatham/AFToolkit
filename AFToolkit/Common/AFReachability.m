@import CoreFoundation;

#import "AFReachability.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>


#pragma mark Constants

NSString * const AFReachability_StateKeyPath = @"state";


#pragma mark - Class Definition

@implementation AFReachability
{
	@private SCNetworkReachabilityRef _reachabilityRef;
}


#pragma mark - Class Methods

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
	AFReachability *reachability = (__bridge AFReachability *)info;
	[reachability updateStateForFlags: flags];
}


#pragma mark - Properties

- (void)setState: (AFReachabilityState)state
{
	_state = state;
}


#pragma mark - Constructors

+ (AFReachability *)reachabilityWithHostName: (NSString *)hostName;
{
	const char *hostNameCString = [hostName cStringUsingEncoding: NSASCIIStringEncoding];

    AFReachability *result = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, hostNameCString);
    if(reachability != NULL)
    {
        result = [[self alloc]
			init];
        if(result != NULL)
        {
            result->_reachabilityRef = reachability;
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

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_state = AFReachabilityStateUnknown;
	
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


#pragma mark - Public Methods

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
    if(_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


#pragma mark - Private Methods

- (void)updateStateForFlags: (SCNetworkReachabilityFlags)flags
{
	AFReachabilityState state = AFReachabilityStateOffline;
	
	SCNetworkReachabilityFlags updateFlags;
	BOOL success = SCNetworkReachabilityGetFlags(_reachabilityRef, &updateFlags);
	
	// Determine state.
    if (success == YES
		&& (updateFlags & kSCNetworkFlagsReachable)
		&& !(updateFlags & kSCNetworkFlagsConnectionRequired))
    {
        // Target host is reachable.
        state = AFReachabilityStateOnline;
    }
	else
	{
		// Target host is not reachable.
		state = AFReachabilityStateOffline;
	}
	
	// Set state, if required.
	if (self.state != state)
	{
		AFLog(AFLogLevelDebug, @"Reachability: %@", state == AFReachabilityStateOnline
			? @"ONLINE"
			: @"OFFLINE");
		self.state = state;
	}
}


@end