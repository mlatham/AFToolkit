#import "NSObject+Runtime.h"
#import <objc/runtime.h>


#pragma mark Constants

// Use the addresses as the key.
static char TEMPLATE_KEY;


#pragma mark - Class Definition

@implementation NSObject (Runtime)


#pragma mark - Public Methods

+ (instancetype)template
{
	id instance = (id)objc_getAssociatedObject(self, &TEMPLATE_KEY);
	
	// Create the property info map on demand.
	if (instance == nil)
	{
		instance = [self alloc];
	
		objc_setAssociatedObject(self, &TEMPLATE_KEY, instance, OBJC_ASSOCIATION_RETAIN);
	}
	
	return instance;
}


@end