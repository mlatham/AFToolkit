import SwiftUI

/// Generic swift view wrapper.
public struct SView<View: UIView>: UIViewRepresentable {
	public let configuration: (View) -> Void
	
	public init(configuration: @escaping (View) -> Void) {
		self.configuration = configuration
	}

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> View { View(frame: .zero) }
    public func updateUIView(_ uiView: View, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
