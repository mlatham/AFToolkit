import Foundation
import Alamofire

public class HttpClient: NSObject {

	// MARK: - Functions

	@discardableResult
	public func get<ModelType: Decodable>(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<ModelType>) -> Void) -> DataRequest? {
		return request(url, method: .get, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func getJSON(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<Any>) -> Void) -> DataRequest? {
		return requestJSON(url, method: .get, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func post<ModelType: Decodable>(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<ModelType>) -> Void) -> DataRequest? {
		return request(url, method: .post, parameters: parameters, headers: headers, completion: completion)
	}

	@discardableResult
	public func postJSON(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<Any>) -> Void) -> DataRequest? {
		return requestJSON(url, method: .post, parameters: parameters, headers: headers, completion: completion)
	}

	@discardableResult
	public func put<ModelType: Decodable>(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<ModelType>) -> Void) -> DataRequest? {
		return request(url, method: .put, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func putJSON(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<Any>) -> Void) -> DataRequest? {
		return requestJSON(url, method: .put, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func delete<ModelType: Decodable>(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<ModelType>) -> Void) -> DataRequest? {
		return request(url, method: .delete, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func deleteJSON(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<Any>) -> Void) -> DataRequest? {
		return requestJSON(url, method: .delete, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func head<ModelType: Decodable>(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<ModelType>) -> Void) -> DataRequest? {
		return request(url, method: .head, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func headJSON(
		_ url: String,
		parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		completion: @escaping (AFDataResponse<Any>) -> Void) -> DataRequest? {
		return requestJSON(url, method: .head, parameters: parameters, headers: headers, completion: completion)
	}
	
	@discardableResult
	public func request<ModelType: Decodable>(
		_ url: String,
		method: HTTPMethod = .get,
		parameters: Parameters? = nil,
		encoding: ParameterEncoding = URLEncoding.default,
		headers: HTTPHeaders? = nil,
		interceptor: RequestInterceptor? = nil,
		completion: @escaping (AFDataResponse<ModelType>) -> Void) -> DataRequest? {
		let urlString = url
		guard let url = URL(string: url) else {
			log(.error, "URL invalid: \(urlString)")
			completion(AFDataResponse(
				request: nil,
				response: nil,
				data: nil,
				metrics: nil,
				serializationDuration: 0,
				result: .failure(AFError.invalidURL(url: urlString))))
			return nil
		}
		
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		
		return AF.request(
			url,
			method: method,
			parameters: parameters,
			encoding: encoding,
			headers: headers,
			interceptor: interceptor)
			.validate()
			.responseDecodable(of: ModelType.self, decoder: decoder) { response in
				#if DEBUG
				self.log(.debug, "\(response.prettyDescription())")
				#endif
				
				completion(response)
			}
	}
	
	@discardableResult
	public func requestJSON(
		_ url: String,
		method: HTTPMethod = .get,
		parameters: Parameters? = nil,
		encoding: ParameterEncoding = URLEncoding.default,
		headers: HTTPHeaders? = nil,
		interceptor: RequestInterceptor? = nil,
		completion: @escaping (AFDataResponse<Any>) -> Void) -> DataRequest? {
		let urlString = url
		guard let url = URL(string: url) else {
			log(.error, "URL invalid: \(urlString)")
			completion(AFDataResponse(
				request: nil,
				response: nil,
				data: nil,
				metrics: nil,
				serializationDuration: 0,
				result: .failure(AFError.invalidURL(url: urlString))))
			return nil
		}
		
		return AF.request(
			url,
			method: method,
			parameters: parameters,
			encoding: encoding,
			headers: headers,
			interceptor: interceptor)
			.validate()
			.responseJSON { response in
				#if DEBUG
				self.log(.debug, "\(response.prettyDescription())")
				#endif
				
				completion(response)
			}
	}
	
	/// Constructs the value of a basic authorization header, from the provided ID and password.
	public static func basicAuthorizationHeaderString(_ id: String, _ password: String) -> String {
		let basicAuthorizationCredentialsString = "\(id):\(password)"
		let basicAuthorizationCredentialsData = basicAuthorizationCredentialsString.data(using: .utf8)
		let base64AuthCredentials = basicAuthorizationCredentialsData?.base64EncodedString()
		return "Basic \(base64AuthCredentials ?? "")"
	}
	
	/// Constructs the value of a bearer authorization header, given an oauth token.
	public static func bearerAuthorizationHeaderString(_ token: String) -> String {
		return "Bearer \(token)"
	}
	
	/// Constructs the value of a user agent header string, combining the app's provided name with its version.
	public static func userAgentHeaderString(appName: String) -> String {
		let infoDictionary = Bundle.main.infoDictionary
		let shortVersionString = infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
		return "\(appName)/\(shortVersionString)"
	}
}
