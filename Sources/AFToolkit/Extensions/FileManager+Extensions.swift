import Foundation

public extension FileManager {

	static func mainBundleUrl(for filename: String): URL {
		let filenameNSString: NSString = filename
		let fileBasename = filenameNSString.lastPathComponent.stringByDeleteingPathExtension
		let fileExtension = filenameNSString.pathExtension
		return Bundle.main.url(forResource: fileBasename, withExtension: fileExtension)
	}

	static func url(for directory: SearchPathDirectory,
		in mask: SearchPathDomainMask = .userDomainMask): URL {
		return FileManager.default.urls(for: directory, in: mask).first
	}
	
	static func fileExists(
		filename: String,
		for directory: SearchPathDirectory,
		in mask: SearchPathDomainMask = .userDomainMask) {
		let directoryURL = url(for: directory, in: mask)
		let url = directoryURL.appendingPathComponent(filename)
		var isDirectory = false
		let exists = FileManager.default.fileExists(
			atPath: url?.path,
			isDirectory: &isDirectory)
		return isDirectory && exists
	}
	
	static func urlByAppending(
		path: String,
		for directory: SearchPathDirectory,
		in mask: SearchPathDomainMask = .userDomainMask) -> URL {
		let directoryURL = url(for: directory, in: mask)
		let url = directoryURL.appendingPathComponent(path)
		return url
	}
	
	static func copyFile(atURL: URL, toURL: URL, overwrite: Bool) {
		// Handle file already existing.
		if (FileManager.default.fileExists(atPath: toURL.path)) {
			// Skip if not overwriting.
			if (overwrite == NO) {
				return true
			}
			
			// Otherwise, delete file (or abort if delete fails).
			var error: NSError = nil
			if (!FileManager.default.removeItem(at: toURL, error: &error)) {
				log(.error, "Failed to delete file at '\(toURL)' before overwiting: \(error)")
				return false
			}
		}
		
		// Copy file.
		var error: NSError = nil
		FileManager.default.copyItem(atURL: atURL, toURL: toURL, error: &error)
			
		// Handle errors.
		if (error != nil) {
			log(.error, "Failed to copy file from '\(atURL)' to '\(toURL)': \(error)")
			return false
		}
		
		// Copied successfully.
		return true
	}
}
