

#pragma mark Class Interface

@interface AFPropertyInfo : NSObject


#pragma mark - Properties

// Property class, or nil if the property is not a pointer to a class type.
@property (nonatomic, strong, readonly) Class propertyClass;

// Property class name, or nil if the property is not a pointer to a class type.
@property (nonatomic, strong, readonly) NSString *propertyClassName;

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyType;
@property (nonatomic, copy) NSString *customGetterSelectorName;
@property (nonatomic, copy) NSString *customSetterSelectorName;

@property (nonatomic, assign) BOOL isWeak;
@property (nonatomic, assign) BOOL isCopy;
@property (nonatomic, assign) BOOL isRetain;
@property (nonatomic, assign) BOOL isDynamic;
@property (nonatomic, assign) BOOL isReadonly;
@property (nonatomic, assign) BOOL isNonatomic;


@end // @interface AFPropertyInfo