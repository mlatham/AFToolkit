@import QuartzCore;

#import "UIView+Render.h"


#pragma mark Class Definition

@implementation UIView (Render)


#pragma mark - Properties


#pragma mark - Public Methods

- (UIImage *)render
{
	// Begin drawing. Note that passing in a scale of 0.0 uses the current view's scale.
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
 
	// Clear the context to black.
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor blackColor] set];
	CGContextFillRect(context, self.bounds);
 
	// Render in the view's layer.
	[self.layer renderInContext: context];
 
	// Get rendered layer image.
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

	// End drawing.
	UIGraphicsEndImageContext();
	
	// Return the rendered image.
	return image;
}


@end