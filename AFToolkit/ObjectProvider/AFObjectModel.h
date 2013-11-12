

#pragma mark Protocol

@protocol AFObjectModel<NSObject>


#pragma mark - Required Methods

@required

+ (NSArray *)keyPathsForIdentity;

+ (NSArray *)collectionPropertyKeyPaths;

+ (NSDictionary *)valueKeyPathsByPropertyKeyPath;

+ (NSDictionary *)transformersByPropertyKeyPath;


@optional

+ (void)update: (id)model
	withValues: (NSDictionary *)values;


@end