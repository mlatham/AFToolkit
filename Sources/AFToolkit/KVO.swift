import Foundation

public class KVO: NSObject {

	public enum Errors: Error {
		case invalidKVO(String)
	}

	private class Binding {
		let selector: Selector
		init(_ selector: Selector) {
			self.selector = selector
		}
	}
	
	private class Context {
		weak var observable: NSObject?
		var keyPathBindings: [String: Binding] = [:]
		init(_ observable: NSObject) {
			self.observable = observable
		}
	}
	
	
	// MARK: - Properties
	
	private var _contexts: [Context] = []
	private weak var _target: NSObject?
	
	var callOnUIThread = true
	
	
	// MARK: - Inits
	
	public init(target: NSObject) {
		_target = target
	}
	
	
	// MARK: - Deinit
	
	deinit {
		removeAllObservers()
	}
	
	
	// MARK: - Functions
	
	public func startObserving(_ observable: NSObject,
		forKeyPath keyPath: String,
		options: NSKeyValueObservingOptions = [.new, .initial],
		selector: Selector) throws {
		// Get context structure (or create one).
		var context = _contextForObservable(observable)
		if context == nil {
			// Create new context.
			let newContext = Context(observable)
			context = newContext
			
			// Add context.
			_contexts.append(newContext)
		}
		
		
		if context?.keyPathBindings[keyPath] != nil {
			// Throw an exception if the binding already exists.
			throw Errors.invalidKVO("KVO already observing for keypath: \(keyPath)")
		}
		
		// Create binding.
		let binding = Binding(selector)
		
		// Add binding to array.
		context?.keyPathBindings[keyPath] = binding

		// Start observing.
		observable.addObserver(self,
			forKeyPath: keyPath,
			options: options,
			context: nil)
	}
	
	public func stopObserving(_ observable: NSObject, forKeyPath keyPath: String) {
		// Skip if keypath isn't mapped.
		guard let context = _contextForObservable(observable),
			context.keyPathBindings[keyPath] != nil else {
			return
		}
		
		// Remove observer.
		context.observable?.removeObserver(self, forKeyPath: keyPath)
		
		// Remove binding.
		context.keyPathBindings.removeValue(forKey: keyPath)
	}
	
	public func removeAllObservers() {
		// Remove all remaining contexts.
		for context in _contexts {
			// Stop observing for all keypaths.
			for keyPath in context.keyPathBindings.keys {
				// Stop observing.
				context.observable?.removeObserver(self, forKeyPath: keyPath)
			}
		}
		
		// Clear the contexts array.
		_contexts.removeAll()
	}
	
	public override func observeValue(
		forKeyPath keyPath: String?,
		of object: Any?,
		change: [NSKeyValueChangeKey : Any]?,
		context: UnsafeMutableRawPointer?) {
		// Skip if keypath isn't mapped.
		guard let observable = object as? NSObject,
			let context = _contextForObservable(observable),
			let keyPath = keyPath,
			let binding = context.keyPathBindings[keyPath] else {
			return
		}
		
		// Skip if target isn't set, or is deallocated.
		if _target == nil {
			return
		}
		
		if (callOnUIThread && !Thread.isMainThread)
		{
			// Call back on the UI-thread.
			DispatchQueue.main.async { [weak self] in
				self?._notify(binding, change: change, observable: observable)
			}
		} else {
			// Call back directly.
			_notify(binding, change: change, observable: observable)
		}
	}
}


// MARK: - Helper Functions

private extension KVO {
	private func _notify(_ binding: Binding,
		change: [NSKeyValueChangeKey : Any]?,
		observable: Any?) {
		_target?.perform(binding.selector, with: change, with: observable)
	}
	
	private func _contextForObservable(_ observable: NSObject?) -> Context? {
		// Find the context.
		for context in _contexts {
			if context.observable == observable {
				return context
			}
		}
		
		// Or return nil.
		return nil
	}
}
