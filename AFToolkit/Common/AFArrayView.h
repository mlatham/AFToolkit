#import "AFArray.h"


#pragma mark Type Definitions

typedef NSComparisonResult (^AFArrayViewComparator)(id lhs, id rhs);
typedef BOOL (^AFArrayViewFilter)(id object);


#pragma mark - Enumerations

typedef enum
{
	AFArrayViewSortOrderDescending,
	AFArrayViewSortOrderAscending
	
} AFArrayViewSortOrder;


#pragma mark - Class Interface

// THIS CLASS IS NOT THREAD-SAFE
@interface AFArrayView : AFArray


#pragma mark - Properties

@property (nonatomic, copy) AFArrayViewComparator comparator;

@property (nonatomic, copy) AFArrayViewFilter filter;

@property (nonatomic, assign) AFArrayViewSortOrder sortOrder;

@property (nonatomic, strong) AFArray *source;


@end // @interface AFArrayView