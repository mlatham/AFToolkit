import ReSwift

public typealias MiddlewareAction<State: StateType> = (Action, MiddlewareHelper<State>.Context) -> Action?

// Source: http://bit.ly/2DCMmyX
public struct MiddlewareHelper<State: StateType> {
	public struct Context {
		/// Closure that can be used to emit additional actions, that go through the middleware.
		/// NOTE: Do not dispatch the current action, that will lead to an infinite loop. Use `next` instead.
		public let dispatch: DispatchFunction
		public let getState: () -> State?
		
		/// Closure that is returned from the middleware, which forwards the action to the reducer.
		/// In case of an async operation, return `nil` and use `dispatch` within the callback for other actions.
		public let next: DispatchFunction
		
		public var state: State? {
			return getState()
		}
		
		/// Maps the context's state to substate
		public func map<Substate: StateType>(_ transform: @escaping (State?) -> Substate?) -> MiddlewareHelper<Substate>.Context {
			let substateClosure = { transform(self.state) }
			
			return MiddlewareHelper<Substate>.Context(dispatch: dispatch, getState: substateClosure, next: next)
		}
	}
	
	/// Uses the UNMiddleWareAction closure to create the ReSwift Middleware.
	public static func create(_ middleware: @escaping MiddlewareAction<State>) -> Middleware<State> {
		return { dispatch, getState in
			return { next in
				return { action in
					let context = Context(dispatch: dispatch, getState: getState, next: next)
					
					if let newAction = middleware(action, context) {
						next(newAction)
					}
				}
			}
		}
	}
	
	public static func createActionLoggingMiddleware() -> Middleware<State> {
		return create(_actionLoggingMiddleware())
	}
	
	
	// Helper Functions
	
	private static func _actionLoggingMiddleware<State>() -> MiddlewareAction<State> {
		return { action, context in
			#if DEBUG
			print("ACTION: \(action)")
			#endif
			return action
		}
	}
}
