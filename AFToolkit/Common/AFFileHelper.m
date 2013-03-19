#import "AFFileHelper.h"


#pragma mark Private Methods

@interface AFFileHelper ()

@end  // @interface AFFileHelper ()

#pragma mark - Class Variables

static BOOL _classInitialized;
static NSFileManager *_fileManager;
static NSBundle *_mainBundle;
static NSURL *_documentsURL;
static NSURL *_cacheURL;


#pragma mark - Helper Methods

AF_INLINE NSURL *mainBundleURLForFile(NSString *file)
{	
	NSString *fileName = [[file lastPathComponent] stringByDeletingPathExtension];
	NSString *extension = [file pathExtension];
	return [_mainBundle URLForResource: fileName 
		withExtension: extension];
}


#pragma mark - Class Definition

@implementation AFFileHelper


#pragma mark - Constructors

+ (void)initialize
{
	if (_classInitialized == NO)
	{
		_classInitialized = YES;
		
		// use default file manager
		_fileManager = [NSFileManager defaultManager];
		
		// use main bundle
		_mainBundle = [NSBundle mainBundle];
		
		// get documents folder root
		_documentsURL = [[_fileManager 
            URLsForDirectory: NSDocumentDirectory 
            inDomains: NSUserDomainMask] 
			objectAtIndex: 0]; 
				
		// get cache folder root
		 _cacheURL = [[_fileManager 
            URLsForDirectory: NSCachesDirectory
            inDomains: NSUserDomainMask] 
			objectAtIndex: 0];
	}
}


#pragma mark - Public Methods

+ (BOOL)mainBundleFileExists: (NSString *)file
{
	NSURL *url = mainBundleURLForFile(file);
	return url != nil;
}

+ (NSURL *)mainBundleURLForFile: (NSString *)file
{
	NSURL *url = mainBundleURLForFile(file);
    return url;
}

+ (BOOL)documentsDirectoryExists: (NSString *)directory
{
	NSURL *url = [[self documentsURL] URLByAppendingPathComponent: directory 
		isDirectory: YES];
	BOOL isDirectory = NO;
	BOOL exists = [_fileManager fileExistsAtPath: [url path]
		isDirectory: &isDirectory];
	return exists && isDirectory;
}

+ (BOOL)documentsFileExists: (NSString *)file
{
	NSURL *url = [[self documentsURL] URLByAppendingPathComponent: file 
		isDirectory: NO];
	return [_fileManager fileExistsAtPath: [url path] 
		isDirectory: NO];
}
	
+ (NSURL *)documentsURL
{
	return _documentsURL;
}

+ (NSURL *)documentsURLByAppendingPath: (NSString *)path
{
	NSURL *url = [[self documentsURL] URLByAppendingPathComponent: path];
    return url;
}

+ (BOOL)cacheDirectoryExists: (NSString *)directory
{
	NSURL *url = [[self cacheURL] URLByAppendingPathComponent: directory 
		isDirectory: YES];
	BOOL isDirectory = NO;
	BOOL exists = [_fileManager fileExistsAtPath: [url path]
		isDirectory: &isDirectory];
	return exists && isDirectory;
}

+ (BOOL)cacheFileExists: (NSString *)file
{
	NSURL *url = [[self cacheURL] URLByAppendingPathComponent: file 
		isDirectory: NO];
	return [_fileManager fileExistsAtPath: [url path] 
		isDirectory: NO];
}

+ (NSURL *)cacheURL
{
	return _cacheURL;
}

+ (NSURL *)cacheURLByAppendingPath: (NSString *)path;
{
	NSURL *url = [[self cacheURL] URLByAppendingPathComponent: path];
    return url;
}
	
+ (BOOL)copyFileFrom: (NSURL *)sourceURL
	to: (NSURL *)targetURL
	overwrite: (BOOL)overwrite
{
	// handle file already existing
    if ([_fileManager fileExistsAtPath: [targetURL path]] == YES)
    {
        // skip if not overwriting
        if (overwrite == NO)
        {
            return YES;
        }
        
        // otherwise, delete file (or abort if delete fails
        NSError *error = nil;
        if ([_fileManager removeItemAtURL: targetURL 
            error: &error] == NO)
        {
            AFLog(AFLogLevelError, @"Failed to delete file at '@' before overwiting: %@",
                targetURL, [error localizedDescription]);
            return NO;
        }
    }
    
    // copy file
    NSError *error = nil;
    [_fileManager copyItemAtURL: sourceURL 
        toURL: targetURL 
		error: &error];
        
    // handle error
    if (error != nil)
    {
        AFLog(AFLogLevelError, @"Failed to copy file from '%@' to '%@': %@", sourceURL, 
            targetURL, [error localizedDescription]);
        return NO;
    }
    
	// return success
	return YES;
}

+ (BOOL)createDirectoryAtURL: (NSURL *)url
	withIntermediateDirectories: (BOOL)createIntermediates
	attributes: (NSDictionary *)attributes
	error: (NSError **)error
{
	// create the directory
	return [_fileManager createDirectoryAtURL: url
		withIntermediateDirectories: createIntermediates
		attributes: attributes
		error: error];
}

+ (BOOL)deleteFile: (NSURL *)targetURL
{
	// fail if file doesn't exist
    NSString *targetPath = [targetURL path];
    if ([_fileManager fileExistsAtPath: targetPath] == NO)
    {
        return NO;
    }
    
    // delete file
	NSError *error = nil;
    [_fileManager removeItemAtPath: targetPath 
        error: &error];
		
	// handle error
	if (error != nil)
	{
		AFLog(AFLogLevelError, @"Failed to delete file '%@' : %@", targetURL, 
			[error localizedDescription]);
        return NO;
	}
	
	// return success
	return YES;
}

+ (BOOL)directoryExists: (NSURL *)url
{
	BOOL isDirectory = NO;
	BOOL exists = [_fileManager fileExistsAtPath: [url path]
		isDirectory: &isDirectory];
	return exists && isDirectory;
}

+ (BOOL)fileExists: (NSURL *)url
{
	BOOL exists = [_fileManager fileExistsAtPath: [url path]];
	return exists;
}


@end  // @interface AFFileHelper