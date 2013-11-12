

#pragma mark Class Interface

@interface AFFileHelper : NSObject


#pragma mark - Methods

+ (BOOL)mainBundleFileExists: (NSString *)file;
+ (NSURL *)mainBundleURLForFile: (NSString *)file;

+ (BOOL)documentsDirectoryExists: (NSString *)directory;
+ (BOOL)documentsFileExists: (NSString *)file;
+ (NSURL *)documentsURL;
+ (NSURL *)documentsURLByAppendingPath: (NSString *)path;

+ (BOOL)cacheDirectoryExists: (NSString *)directory;
+ (BOOL)cacheFileExists: (NSString *)file;
+ (NSURL *)cacheURL;
+ (NSURL *)cacheURLByAppendingPath: (NSString *)path;
	
+ (BOOL)copyFileFrom: (NSURL *)sourceURL
	to: (NSURL *)targetURL
	overwrite: (BOOL)overwrite;

+ (BOOL)createDirectoryAtURL: (NSURL *)url
	withIntermediateDirectories: (BOOL)createIntermediates
	attributes: (NSDictionary *)attributes
	error: (NSError **)error;

+ (BOOL)deleteFile: (NSURL *)targetURL;

+ (BOOL)directoryExists: (NSURL *)url;
+ (BOOL)fileExists: (NSURL *)url;


@end