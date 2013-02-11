

#pragma mark Class Interface

@interface AFKVO : NSObject


#pragma mark - Constructors

- (id)initWithTarget: (NSObject *)target;


#pragma mark - Methods

- (void)startObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath
    options: (NSKeyValueObservingOptions)options
    selector: (SEL)selector;

- (void)stopObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath;


@end  // @interface AFKVO