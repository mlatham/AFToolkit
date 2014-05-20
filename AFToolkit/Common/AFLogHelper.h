#import "Foundation/Foundation.h"


#pragma mark Enumerations

typedef enum
{
	AFLogLevelTrace	= 5,
	AFLogLevelDebug	= 4,
	AFLogLevelInfo	= 3,
	AFLogLevelWarn	= 2,
	AFLogLevelError	= 1,
	AFLogLevelFatal	= 0
			
} AFLogLevel;


#pragma mark - Static Variables

static AFLogLevel AFApplicationLogLevel = AFLogLevelDebug;


#pragma mark - Methods

static inline void AF_log(AFLogLevel level, NSString *format, ...)
{
	// get a reference to the arguments that follow the format parameter
	va_list argList;
	va_start(argList, format);
	
	if (format == nil) 
	{
		return;
	}
	
	// determine log level prefix
	const char *linePrefix = NULL;
	
	// disabled log level
	if (level > AFApplicationLogLevel)
	{
		return;
	}
	
	switch (level)
	{
		case AFLogLevelFatal:
		{
			linePrefix = "FATAL   ";
			break;
		}
		case AFLogLevelError:
		{
			linePrefix = "ERROR   ";
			break;
		}
		case AFLogLevelWarn:
		{
			linePrefix = "WARN    ";
			break;
		}
		case AFLogLevelInfo:
		{
			linePrefix = "INFO    ";
			break;
		}
		case AFLogLevelDebug:
		{
			linePrefix = "DEBUG   ";
			break;
		}
		case AFLogLevelTrace:
		{
			linePrefix = "TRACE   ";
			break;
		}
	}

	// perform format string argument substitution
	NSString *formattedLine = [[NSString alloc] 
		initWithFormat: format 
		arguments: argList];
	
	// reinstate %% escapes
	const char *line = [[formattedLine stringByReplacingOccurrencesOfString: @"%%" 
		withString:@"%%%%"] 
			UTF8String];
	
	// print
	printf("%s: %s\n", linePrefix, line);
	
	va_end(argList);
}

