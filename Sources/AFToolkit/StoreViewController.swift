import Foundation
import ReSwift
import UIKit

open class StoreViewController<State: StateType>: UIViewController, StoreSubscriber {

	// MARK: - Properties

	private var _store: Store<State>?
	public var store: Store<State>? {
		get { return _store }
		set {
			// If subscribed, unsubscribe then re-subscribe to the new store.
			let resubscribe = isSubscribed
			if isSubscribed {
				setSubscribed(false)
			}
			
			// Update the value.
			_store = newValue
			
			// Re-subscribe if necessary.
			if resubscribe {
				setSubscribed(true)
			}
		}
	}
	
	private(set) var isSubscribed: Bool = false
	
	
	// MARK: - Functions
	
	public func setSubscribed(_ subscribed: Bool) {
		guard isSubscribed != subscribed else { return }
		guard let store = store else {
			log(.debug, "Calling setSubscribed without a store.")
			return
		}
		
		// Subscribe or unsubscribe.
		if (subscribed) {
			store.subscribe(self)
		} else {
			store.unsubscribe(self)
		}
		
		// Update the tracking property.
		isSubscribed = subscribed
	}
	
	open func newState(state: State) {
	}
}
