import Foundation

//typealias CCharHandle = UnsafeMutablePointer<UnsafeMutablePointer<CChar>>
//typealias CCharPointer = UnsafeMutablePointer<CChar>
//typealias CVoidPointer = UnsafeMutableRawPointer

typealias ErrorPointer = AutoreleasingUnsafeMutablePointer<NSError?>
typealias SqliteStatement = OpaquePointer
typealias SqliteDatabase = OpaquePointer

typealias SqliteTask = (SqliteDatabase?, inout Bool) -> AnyObject
typealias SqliteCompletion = (AnyObject?, Bool) -> Void
