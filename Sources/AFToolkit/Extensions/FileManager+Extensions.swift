import Foundation

public extension FileManager {

	static func mainBundleUrl(for filename: String) -> URL? {
		let filenameURL = URL(string: filename)
		let fileBasename = filenameURL?.deletingPathExtension().lastPathComponent
		let fileExtension = (filenameURL?.lastPathComponent as? NSString)?.pathExtension
		return Bundle.main.url(forResource: fileBasename, withExtension: fileExtension)
	}

	static func url(for directory: SearchPathDirectory,
		in mask: SearchPathDomainMask = .userDomainMask) -> URL? {
		return FileManager.default.urls(for: directory, in: mask).first
	}
	
	static func fileExists(
		filename: String,
		for directory: SearchPathDirectory,
		in mask: SearchPathDomainMask = .userDomainMask) -> Bool {
		let directoryURL = url(for: directory, in: mask)
		guard let url = directoryURL?.appendingPathComponent(filename) else {
			return false
		}
		var isDirectory: ObjCBool = false
		let exists = FileManager.default.fileExists(
			atPath: url.path,
			isDirectory: &isDirectory)
		return isDirectory.boolValue && exists
	}
	
	static func urlByAppending(
		path: String,
		for directory: SearchPathDirectory,
		in mask: SearchPathDomainMask = .userDomainMask) -> URL? {
		let directoryURL = url(for: directory, in: mask)
		let url = directoryURL?.appendingPathComponent(path)
		return url
	}
	
	static func copyFile(atURL: URL, toURL: URL, overwrite: Bool) -> Bool {
		// Handle file already existing.
		if (FileManager.default.fileExists(atPath: toURL.path)) {
			// Skip if not overwriting.
			if (!overwrite) {
				return true
			}
			
			// Otherwise, delete file (or abort if delete fails).
			do {
				try FileManager.default.removeItem(at: toURL)
			} catch {
				Logger.defaultLogger.log(.error, "Failed to delete file at '\(toURL)' before overwiting: \(error)")
				return false
			}
		}
		
		do {
			// Copy file.
			try FileManager.default.copyItem(at: atURL, to: toURL)
		} catch {
			Logger.defaultLogger.log(.error, "Failed to copy file from '\(atURL)' to '\(toURL)': \(error)")
			return false
		}
		
		// Copied successfully.
		return true
	}
}
