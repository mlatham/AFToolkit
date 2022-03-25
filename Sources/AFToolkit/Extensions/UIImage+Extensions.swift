import Foundation
import UIKit

public extension UIImage {
	
	// MARK: - Functions


	/// Creates a new bitmap context from this image. This converts whatever the color space of the image is to RGB.
	/// Adapted from: https://gist.github.com/jokester/948616a1b881451796d6
	func createBitmapContext() -> CGContext? {
		guard let cgImage = cgImage else { return nil }

		// Get image width, height
		let pixelsWide = cgImage.width
		let pixelsHigh = cgImage.height

		// Declare the number of bytes per row. Each pixel in the bitmap in this
		// example is represented by 4 bytes; 8 bits each of red, green, blue, and alpha.
		let bitmapBytesPerRow = pixelsWide * 4
		let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)

		// Use the generic RGB color space.
		let colorSpace = CGColorSpaceCreateDeviceRGB()

		// Allocate memory for image data. This is the destination in memory
		// where any drawing to the bitmap context will be rendered.
		let bitmapData = malloc(bitmapByteCount)
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

		// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
		// per component. Regardless of what the source image format is
		// (CMYK, Grayscale, and so on) it will be converted over to the format
		// specified here by CGBitmapContextCreate.
		let context = CGContext(
			data: bitmapData,
			width: pixelsWide,
			height: pixelsHigh,
			bitsPerComponent: 8,
			bytesPerRow: bitmapBytesPerRow,
			space: colorSpace,
			bitmapInfo: bitmapInfo.rawValue)

		// Draw the image onto the context.
		let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)
		context?.draw(cgImage, in: rect)

		return context
    }
	
	/// Subscript accessor to get color at a given point. This first extracts RGB data from an image, which is a
	/// pretty costly operation, so this accessor is best used for single queries, not iterating over bitmap contents.
	subscript (x: Int, y: Int) -> UIColor? {
		// Nil if point is outside image coordinates.
		guard (x >= 0 && x < Int(size.width) && y >= 0 && y < Int(size.height)),
		 	let context = createBitmapContext(),
		 	let pixelData = context.data else {
			return nil
		}
		
		let data = pixelData.assumingMemoryBound(to: UInt8.self)
		let rgba = _getRGBAValue(data: data, x: x, y: y)
		return UIColor(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
	}
	
	func averageColor(rect: CGRect) -> UIColor? {
		// Nil if rect is outside image bounds.
		guard (rect.minX >= 0 && rect.minY >= 0 && rect.maxX <= size.width && rect.maxY <= size.height),
		 	let context = createBitmapContext(),
		 	let pixelData = context.data else {
			return nil
		}
		
		let data = pixelData.assumingMemoryBound(to: UInt8.self)
		var pixelCount: CGFloat = 0
		
		var sumRGBA: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) = (r: 0, g: 0, b: 0, a: 0)
		for x: Int in Int(rect.minX)...Int(rect.maxX) {
			for y: Int in Int(rect.minY)...Int(rect.maxY) {
				let rgba = _getRGBAValue(data: data, x: x, y: y)
				sumRGBA.r += rgba.r
				sumRGBA.g += rgba.g
				sumRGBA.b += rgba.b
				sumRGBA.a += rgba.a
				pixelCount += 1
			}
		}
		
		// Calculate the arithmetic mean (centroid of all RGBA points).
		let averageRGBA: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) = (
			r: sumRGBA.r / pixelCount,
			g: sumRGBA.g / pixelCount,
			b: sumRGBA.b / pixelCount,
			a: sumRGBA.a / pixelCount)
		return UIColor(red: averageRGBA.r, green: averageRGBA.g, blue: averageRGBA.b, alpha: averageRGBA.a)
	}
	
	
	// MARK: - Helper Functions
	
	private func _getRGBAValue(data: UnsafeMutablePointer<UInt8>, x: Int, y: Int)
		-> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
		let numberOfComponents = 4
		let pixelInfo: Int = (Int(size.width) * y + x) * numberOfComponents
		
		// Gets and converts the values from 0-255 to 0-1.
		return (
			r: CGFloat(data[pixelInfo + 1]) / 255.0,
			g: CGFloat(data[pixelInfo + 2]) / 255.0,
			b: CGFloat(data[pixelInfo + 3]) / 255.0,
			a: CGFloat(data[pixelInfo]) / 255.0)
	}
}
