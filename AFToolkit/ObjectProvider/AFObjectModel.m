#import "AFObjectModel.h"


#pragma mark Class Definition

@implementation AFObjectModel


#pragma mark - Constructors

- (id)initWithClass: (Class)myClass
	idProperties: (NSArray *)idProperties
	propertyKeyMap: (NSDictionary *)propertyKeyMap
	collectionTypeMap: (NSDictionary *)collectionTypeMap
	updateBlock: (AFObjectUpdateBlock)updateBlock
	createBlock: (AFObjectCreateBlock)createBlock;
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_myClass = myClass;
	_idProperties = [idProperties copy];
	_propertyKeyMap = [propertyKeyMap copy];
	_collectionTypeMap = [collectionTypeMap copy];
	_updateBlock = [updateBlock copy];
	_createBlock = [createBlock copy];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

+ (id)objectModelWithClass: (Class)myClass
	idProperties: (NSArray *)idProperties
	propertyKeyMap: (NSDictionary *)propertyKeyMap
	collectionTypeMap: (NSDictionary *)collectionTypeMap
	updateBlock: (AFObjectUpdateBlock)updateBlock
	createBlock: (AFObjectCreateBlock)createBlock
{
	return [[AFObjectModel alloc]
		initWithClass: myClass
		idProperties: idProperties
		propertyKeyMap: propertyKeyMap
		collectionTypeMap: collectionTypeMap
		updateBlock: updateBlock
		createBlock: createBlock];
}


@end // @implementation AFObjectModel