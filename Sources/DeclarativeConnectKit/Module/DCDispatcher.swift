//  Created by AidenJLee on 2023/03/25.
//

import Combine
import Foundation

@available(iOS 15, macOS 10.15, *)
public struct DCDispatcher {
    
    let urlSession: URLSession = .shared
    
	var logLevel: NetworkingLogLevel
	
    // 로그를 위한 DCLogger 인스턴스 생성
	private let logger: DCLogger
	
	init(logLevel: NetworkingLogLevel = .info) {
		self.logger = DCLogger(logLevel: logLevel)
		self.logLevel = logLevel
	}
    
    // Publisher를 반환하는 dispatch 메서드
    func dispatch<ReturnType: Codable>(request: URLRequest, decoder: JSONDecoder?) -> AnyPublisher<ReturnType, NetworkRequestError> {

        // JSONDecoder 인스턴스 생성
        let decoder = decoder ?? JSONDecoder()
        
        // dataTaskPublisher를 사용하여 데이터를 가져옴
        return urlSession
            .dataTaskPublisher(for: request)
            .tryMap({ data, response in
                // HTTPURLResponse로 캐스팅
                guard let HTTPResponse = response as? HTTPURLResponse else {
                    throw NetworkRequestError.unknownError(data)
                }
                // HTTP 상태 코드가 200~299 사이가 아닐 경우 에러 처리
                if !(200...299).contains(HTTPResponse.statusCode) {
                    throw httpError(HTTPResponse.statusCode, data: data)
                }
                // 로그 출력
                self.logger.log(response: response, data: data)
                return data
            })
            // JSON 디코딩
            .decode(type: ReturnType.self, decoder: decoder)
            // 에러 처리
            .mapError { error in
               handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // async/await를 사용하여 데이터를 가져오는 dispatch 메서드
    func dispatch<ReturnType: Codable>(request: URLRequest, decoder: JSONDecoder?) async throws -> ReturnType {

        // JSONDecoder 인스턴스 생성
        let decoder = decoder ?? JSONDecoder()
        
        // async/await를 사용하여 데이터를 가져옴
        let (data, urlResponse) = try await urlSession.data(for: request)
		
		#if DEBUG
		do {
			let response = try JSONDecoder().decode(ReturnType.self, from: data) // Specify ReturnType.self
		} catch let DecodingError.dataCorrupted(context) {
			print("Data corrupted: \(context)")
		} catch let DecodingError.keyNotFound(key, context) {
			print("Key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
		} catch let DecodingError.valueNotFound(value, context) {
			print("Value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
		} catch let DecodingError.typeMismatch(type, context) {
			print("Type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)")
		} catch {
			print("Other decoding error: \(error)")
		}
		#endif
		
        // HTTPURLResponse로 캐스팅
        guard let HTTPResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkRequestError.unknownError(data)
        }
		
        // HTTP 상태 코드가 200~299 사이가 아닐 경우 에러 처리
        if !(200...299).contains(HTTPResponse.statusCode) {
            throw httpError(HTTPResponse.statusCode, data: data)
        }
		
        // 로그 출력
        self.logger.log(response: urlResponse, data: data)
        
        // JSON 디코딩
        let response = try decoder.decode(ReturnType.self, from: data)
        return response
    }

    // HTTP 상태 코드에 따른 에러 처리
    func httpError(_ statusCode: Int, data: Data?) -> NetworkRequestError {
        switch statusCode {
        case 400: return .badRequest(data)
        case 401: return .unauthorized(data)
        case 403: return .forbidden(data)
        case 404: return .notFound(data)
        case 402, 405...499: return .error4xx(statusCode, data: data)
        case 500: return .serverError(data)
        case 503: return .serviceError(statusCode, data: data)
        case 501, 502, 504...599: return .error5xx(statusCode, data: data)
        default: return .unknownError(data)
        }
    }
    
    // 에러 처리
    private func handleError(_ error: Error) -> NetworkRequestError {
        switch error {
        case let error as DecodingError:
            return .decodingError(error.localizedDescription)
        case let error as URLError:
            return .urlSessionFailed(error)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError()
        }
    }
    
    // 디버그 메시지 출력
    private func debugMessage(_ message: String) {
        #if DEBUG
            print("--- Request \(message)")
        #endif
    }
}

// 네트워크 요청 에러 처리
public enum NetworkRequestError: LocalizedError, Equatable {
    case invalidRequest(_ data: Data? = nil)
    case badRequest(_ data: Data? = nil)
    case unauthorized(_ data: Data? = nil)
    case forbidden(_ data: Data? = nil)
    case notFound(_ data: Data? = nil)
    case error4xx(_ code: Int, data: Data? = nil)
    case serverError(_ data: Data? = nil)
    case serviceError(_ code: Int, data: Data? = nil)
    case error5xx(_ code: Int, data: Data? = nil)
    case decodingError(_ description: String)
    case urlSessionFailed(_ error: URLError)
    case unknownError(_ data: Data? = nil)
}
