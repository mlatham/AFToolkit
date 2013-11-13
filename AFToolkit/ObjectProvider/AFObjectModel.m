#import "AFObjectModel.h"


#pragma mark Class Definition

@implementation AFObjectModel


#pragma mark - Constructors

- (id)initWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_key = key;
	_mappings = mappings;
	_transformers = transformers;
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

+ (id)objectModelWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers
{
	return [[AFObjectModel alloc]
		initWithKey: key
		mappings: mappings
		transformers: transformers];
}

+ (id)objectModelWithMappings: (NSDictionary *)mappings
	transformers: (NSDictionary *)transformers
{
	return [[AFObjectModel alloc]
		initWithKey: nil
		mappings: mappings
		transformers: transformers];
}

+ (id)objectModelWithKey: (NSArray *)key
	mappings: (NSDictionary *)mappings
{
	return [[AFObjectModel alloc]
		initWithKey: key
		mappings: mappings
		transformers: nil];
}

+ (id)objectModelWithMappings: (NSDictionary *)mappings
{
	return [[AFObjectModel alloc]
		initWithKey: nil
		mappings: mappings
		transformers: nil];
}


@end