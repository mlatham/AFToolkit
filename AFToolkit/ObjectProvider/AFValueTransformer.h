#import "AFObjectProvider.h"


#pragma mark Class Interface

@interface AFValueTransformer : NSObject


#pragma mark - Instance Methods

// Transforms from the input type to the output type.

- (id)transform: (id)inputValue
	provider: (AFObjectProvider *)provider;

// Transforms from the output type back to the input type.

- (id)reverseTransform: (id)outputValue
	provider: (AFObjectProvider *)provider;


@end