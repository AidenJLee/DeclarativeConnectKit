//  Created by AidenJLee on 2023/03/25.
//

import Combine
import Foundation

@available(iOS 15, macOS 10.15, *)
public struct DConnectKit {
	public var baseURL: String
	public var dispatcher: DCDispatcher
	
	var logLevel: NetworkingLogLevel
	private let logger: DCLogger
	
	public init(baseURL: String, logLevel: NetworkingLogLevel = .debug) {
		self.baseURL = baseURL
		self.logLevel = logLevel
		self.logger = DCLogger(logLevel: logLevel)
		self.dispatcher = DCDispatcher(logger: logger)
	}
	
	public func dispatch<Request: DCRequest>(_ request: Request) -> AnyPublisher<Request.ReturnType, NetworkRequestError> {
		guard let urlRequest: URLRequest = request.asURLRequest(baseURL: baseURL) else {
			return Fail(outputType: Request.ReturnType.self, failure: NetworkRequestError.badRequest()).eraseToAnyPublisher()
		}
		logger.log(request: urlRequest)
		
		typealias RequestPublisher = AnyPublisher<Request.ReturnType, NetworkRequestError>
		let requestPublisher: RequestPublisher = dispatcher.dispatch(request: urlRequest, decoder: request.decoder)
		return requestPublisher.eraseToAnyPublisher()
	}
	
	// Async version
	public func dispatch<Request: DCRequest>(_ request: Request) async throws -> Request.ReturnType {
		guard let urlRequest: URLRequest = request.asURLRequest(baseURL: baseURL) else {
			throw URLError(.badURL)
		}
		logger.log(request: urlRequest)
		
		let returnData: Request.ReturnType = try await dispatcher.dispatch(request: urlRequest, decoder: request.decoder)
		return returnData
	}
}
