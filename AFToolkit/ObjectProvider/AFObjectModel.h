

#pragma mark Protocol

@protocol AFObjectModel<NSObject>


#pragma mark - Required Methods

@required

+ (NSDictionary *)valueKeyPathsByPropertyKeyPath;


@optional

+ (NSArray *)keyPathsForIdentity;

+ (NSDictionary *)transformersByPropertyKeyPath;

+ (void)update: (id)model
	withValues: (NSDictionary *)values;


@end