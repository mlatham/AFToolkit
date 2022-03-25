import UIKit
import SwiftUI

public extension UIColor {

	// MARK: - Properties

	static private var _colorDictionary = { return [String: UIColor]() }()
	

	// MARK: - Inits

    @objc static func color(hex: String) -> UIColor {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        return UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue:  CGFloat(b) / 255,
            alpha: CGFloat(a) / 255)
    }
    
    @objc static func color(imageName: String) -> UIColor {
		if UIColor._colorDictionary[imageName] == nil, let image = UIImage(named: imageName) {
			UIColor._colorDictionary[imageName] = image[0, 0]
		} else {
			Logger.defaultLogger.log(.error, "Failed to load color image: \(imageName)")
		}

		return UIColor._colorDictionary[imageName] ?? .clear
	}
}
