

#pragma mark Property Info Class

@interface AFPropertyInfo : NSObject

@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, strong) NSString *propertyType;
@property (nonatomic, strong) NSString *customGetterSelectorName;
@property (nonatomic, strong) NSString *customSetterSelectorName;

@property (nonatomic, assign) BOOL isWeak;
@property (nonatomic, assign) BOOL isCopy;
@property (nonatomic, assign) BOOL isRetain;
@property (nonatomic, assign) BOOL isDynamic;
@property (nonatomic, assign) BOOL isReadonly;
@property (nonatomic, assign) BOOL isNonatomic;

@end


#pragma mark - Class Interface

@interface NSObject (Runtime)


#pragma mark - Static Methods

// Gets the property info for the provided property name on this class. On
// first access, this method caches that property info in an associated
// object on this class.

+ (AFPropertyInfo *)propertyInfoForPropertyName: (NSString *)propertyName;


#pragma mark - Instance Methods

// Sets a value on this object, changing NSNull values to nil, applying the provided
// transform, handling setting one or many values on a collection type property of
// either NSMutableSet, NSMutableArray or NSMutableOrderedSet.

- (void)setValue: (id)value
	forPropertyName: (NSString *)propertyName
	withTransformer: (NSValueTransformer *)transformer;


@end