/// Entry-point to initialize, configure and access global state for AFToolkit. Namespace to be extended with functions:
/// UT.initializeThing(...): one-time initialization of a thing, such as grid-units or colors.
/// UT.configureThing(...): configuration of a thing, that may happen more than once.
/// UT.Thing: 
public class UT {
	class Style {
		/// Grid unit size used by x functions.
		private(set) static var gridUnitSize: Int = 8
		
		static func initialize(gridUnitSize: Int) {
			UT.Style.gridUnitSize = gridUnitSize
		}
	}
}
