

#pragma mark Protocol

@protocol AFObjectModel<NSObject>


#pragma mark - Required Methods

@required

+ (NSDictionary *)valueKeyPathsByPropertyKeyPath;


@optional

+ (NSArray *)keyPathsForIdentity;

+ (NSDictionary *)transformersByPropertyKeyPath;

+ (void)update: (id)model
	values: (NSDictionary *)values
	provider: (id)provider;


@end