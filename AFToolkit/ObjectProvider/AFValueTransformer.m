#import "AFValueTransformer.h"


#pragma mark Class Definition

@implementation AFValueTransformer


#pragma mark - Public Methods

- (id)transform: (id)inputValue
	provider: (AFObjectProvider *)provider
{
	// Default to identity.
	return inputValue;
}

- (id)reverseTransform: (id)outputValue
	provider: (AFObjectProvider *)provider
{
	// Default to identity.
	return outputValue;
}


@end