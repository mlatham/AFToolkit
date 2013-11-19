

#pragma mark Property Info Class

@interface AFPropertyInfo : NSObject

// Property class, or nil if the property is not a pointer to a class type.
@property (nonatomic, strong, readonly) Class propertyClass;

// Property class name, or nil if the property is not a pointer to a class type.
@property (nonatomic, strong, readonly) NSString *propertyClassName;

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

// Gets a singleton allocated (but uninitialized) instance of this type of object.

+ (instancetype)template;


@end