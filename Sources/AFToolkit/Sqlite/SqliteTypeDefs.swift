import Foundation

typealias sqlite3 = OpaquePointer
typealias CCharHandle = UnsafeMutablePointer<UnsafeMutablePointer<CChar>>
typealias CCharPointer = UnsafeMutablePointer<CChar>
typealias CVoidPointer = UnsafeMutableRawPointer

typealias SqliteTask = (sqlite3, Bool) -> AnyObject
typealias SqliteCompletion = (AnyObject, Bool) -> Void
