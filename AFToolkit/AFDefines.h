
/* Inlining */
#ifndef AF_INLINE
	#define AF_INLINE static inline
#endif

/* Logging */
#ifndef AFLog

	#import "AFLogHelper.h"

	#ifdef DEBUG
		#define AFLog(level, format, ...) AF_log(level, format, ##__VA_ARGS__)
	#else
		#define AFLog(level, format, ...) do { } while (0)
	#endif
	
#endif

#include <assert.h>

/* Assertion */
#ifndef AFAssert
	#ifdef DEBUG
		#define AFAssert(expression) assert(expression)
	#else
		#define AFAssert(expression) do { } while (0)
	#endif
#endif

/* Check Helpers */
AF_INLINE BOOL AFIsNull(id object)
{
	return object == nil 
		|| [[NSNull null] isEqual: object];
}

AF_INLINE BOOL AFIsEmpty(id object)
{
	return AFIsNull(object) == YES
		|| ([object respondsToSelector: @selector(length)]
			&& [object length] == 0)
		|| ([object respondsToSelector: @selector(count)] 
			&& [object count] == 0);
}