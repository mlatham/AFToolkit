#import "AFKVO.h"


#pragma mark Internal Data Structures

@interface AFKVOContext : NSObject
{
	@public __weak NSObject *observable;
	@public __strong NSMutableDictionary *keyPathBindings;
}


@end // @interface AFKVOContext


@implementation AFKVOContext

@end // @implementation AFKVOContext

@interface AFKVOBinding : NSObject
{
	@public SEL selector;
}


@end  // @interface AFKVOBinding


@implementation AFKVOBinding

@end // @implementation AFKVOBinding


#pragma mark - Class Definition

@implementation AFKVO
{
	@private __strong NSMutableArray *_contexts;
	@private __weak NSObject *_target;
}


#pragma mark - Constructors

- (id)initWithTarget: (NSObject *)target
{
    // Abort if base constructor fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
    _contexts = [[NSMutableArray alloc]
        init];
	_target = target;

    // Return initialized instance.
	return self;
}

+ (instancetype)kvoWithTarget: (NSObject *)target
{
	return [[self alloc]
		initWithTarget: target];
}


#pragma mark - Destructors

- (void)dealloc 
{
    // Remove all remaining contexts.
    for (AFKVOContext *context in _contexts)
    {      
		NSMutableDictionary *keyPathBindings = context->keyPathBindings;
		NSObject *observable = context->observable;
		
        // Stop observing for all keypaths.
        for (NSString *keyPath in keyPathBindings)
        {
            // Stop observing.
            [observable removeObserver: self
                forKeyPath: keyPath
				context: (__bridge void *)context];
        }
    }
}


#pragma mark - Public Methods

- (void)startObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath
    options: (NSKeyValueObservingOptions)options
    selector: (SEL)selector
{    
    // Get context structure (or create one).
	AFKVOContext *context = [self _contextForObservable: observable];
    if (context == nil)
    {
        // Create new context.
		context = [[AFKVOContext alloc]
			init];
		context->observable = observable;
		context->keyPathBindings = [[NSMutableDictionary alloc]
			initWithCapacity: 2];
        
        // Add context.
        [_contexts addObject: context];
    }
	
    AFKVOBinding *binding = [context->keyPathBindings
        objectForKey: keyPath];
    if (binding != nil)
    {
        // Throw an exception if the binding already exists.
		@throw [NSException exceptionWithName: @"Invalid KVO"
			reason: [NSString stringWithFormat: @"KVO already observing for keypath: %@", keyPath]
			userInfo: nil];
	}
    
    // Create binding.
    binding = [[AFKVOBinding alloc]
		init];
	binding->selector = selector;
    
    // Add binding to array.
    [context->keyPathBindings setObject: binding
		forKey: keyPath];

    // Start observing.
	[observable addObserver: self
		forKeyPath: keyPath
		options: options
		context: (__bridge void *)context];
}

- (void)startObserving: (NSObject *)observable
	forKeyPath: (NSString *)keyPath
	selector: (SEL)selector
{
	[self startObserving: observable
		forKeyPath: keyPath
		options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
		selector: selector];
}

- (void)stopObserving: (NSObject *)observable
    forKeyPath: (NSString *)keyPath
{
    // Get context structure.
	AFKVOContext *context = [self _contextForObservable: observable];
    if (context == nil)
    {
        return;
    }

	// Skip if keypath isn't mapped.
    AFKVOBinding *binding = [context->keyPathBindings
        objectForKey: keyPath];
    if (binding == nil)
    {
        return;
    }
    
	// Remove observer.
	[context->observable removeObserver: self
		forKeyPath: keyPath];
	
	// Remove binding.
	[context->keyPathBindings removeObjectForKey: keyPath];
}


#pragma mark - Overridden Methods

- (void)observeValueForKeyPath: (NSString *)keyPath 
    ofObject: (id)observable 
    change: (NSDictionary *)change 
    context: (void *)unused
{
    // Get context structure.
	AFKVOContext *context = [self _contextForObservable: observable];
    if (context == nil)
    {
        AFAssert(NO);
        return;
    }
		
	// Skip if keypath isn't mapped.
    AFKVOBinding *binding = [context->keyPathBindings
        objectForKey: keyPath];
    if (binding == nil)
    {
        AFAssert(NO);
        return;
    }
    
	// Skip if target isn't set, or is deallocated.
	if (_target == nil)
	{
		return;
	}
	
	// Notify observer.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[_target performSelector: binding->selector
		withObject: change
		withObject: observable];
#pragma clang diagnostic pop
}


#pragma mark - Private Methods

- (AFKVOContext *)_contextForObservable: (NSObject *)observable
{
	// Find the context.
	for (AFKVOContext *context in _contexts)
	{
		if (context->observable == observable)
		{
			return context;
		}
	}
	
	// Or return nil.
	return nil;
}


@end