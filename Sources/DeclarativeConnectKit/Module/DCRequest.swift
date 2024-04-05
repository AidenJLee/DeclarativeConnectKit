//  Created by AidenJLee on 2023/03/25.
//
import Combine
import Foundation

public protocol DCRequest {
	associatedtype ReturnType: Codable
	var path: String { get } // API 경로
	var method: HTTPMethod { get } // HTTP 메소드
	var contentType: HTTPContentType { get } // HTTP Content-Type
	var queryParams: HTTPParams? { get } // Query Parameter
	var body: Params? { get } // Request Body
	var headers: HTTPHeaders? { get } // HTTP Header
	var multipartData: [MultipartData]? { get } // Multipart Data
	var authToken: String? { get } // 인증 토큰
	var decoder: JSONDecoder? { get } // JSON Decoder
}

public extension DCRequest {
	var method: HTTPMethod { return .get } // 기본 HTTP 메소드는 GET
	var contentType: HTTPContentType { return .json } // 기본 Content-Type은 JSON
	var queryParams: HTTPParams? { return nil } // Query Parameter가 없는 경우 nil
	var body: Params? { return nil } // Request Body가 없는 경우 nil
	var headers: HTTPHeaders? { return nil } // HTTP Header가 없는 경우 nil
	var multipartData: [MultipartData]? { return nil } // Multipart Data가 없는 경우 nil
	var authToken: String? { return nil } // 인증 토큰이 없는 경우 nil
	var decoder: JSONDecoder? { return JSONDecoder() } // JSON Decoder
	var debug: Bool { return false } // Debug 여부
}

// Utility Methods
extension DCRequest {
	func asURLRequest(baseURL: String) -> URLRequest? {
		guard var urlComponents = URLComponents(string: baseURL) else { return nil } // baseURL을 기반으로 URLComponents 생성
		urlComponents.path = "\(urlComponents.path)\(path)" // API 경로 추가
		urlComponents.queryItems = queryItemsFrom(params: queryParams) // Query Parameter 추가
		guard let finalURL = urlComponents.url else { return nil } // URLComponents를 기반으로 URL 생성
		
		let boundary = UUID().uuidString // Multipart Data를 위한 boundary 생성
		
		var request = URLRequest(url: finalURL) // URLRequest 생성
		let defaultHeaders: HTTPHeaders = [
			HTTPHeaderField.contentType.rawValue: "\(contentType.rawValue); boundary=\(boundary)" // Content-Type과 boundary 추가
		]
		request.allHTTPHeaderFields = defaultHeaders.merging(headers ?? [:], uniquingKeysWith: { (current, _) in current }) // HTTP Header 추가
		request.httpMethod = method.rawValue // HTTP 메소드 설정
		request.httpBody = requestBodyFrom(params: body, boundary: boundary) // Request Body 설정
		return request
	}
	
	private func queryItemsFrom(params: HTTPParams?) -> [URLQueryItem]? {
		guard let params = params else { return nil } // Query Parameter가 없는 경우 nil
		return params.map {
			URLQueryItem(name: $0.key, value: $0.value as? String) // Query Parameter 추가
		}
	}
	
	private func requestBodyFrom(params: Params?, boundary: String) -> Data? {
		guard let params = params else { return nil } // Request Body가 없는 경우 nil
		switch contentType {
		case .urlEncoded:
			return params.asPercentEncodedString().data(using: .utf8) // URL Encoded 형식으로 Request Body 생성
		case .json:
			return try? JSONSerialization.data(withJSONObject: params, options: []) // JSON 형식으로 Request Body 생성
		case .multipart:
			return buildMultipartHttpBody(params: body ?? Params(), multiparts: multipartData ?? [], boundary: boundary) // Multipart Data를 포함한 Request Body 생성
		}
	}
	
	private func buildMultipartHttpBody(params: Params, multiparts: [MultipartData], boundary: String) -> Data {
		
		let boundaryPrefix = "--\(boundary)\r\n".data(using: .utf8)! // Multipart Data의 시작 boundary
		let boundarySuffix = "\r\n--\(boundary)--\r\n".data(using: .utf8)! // Multipart Data의 끝 boundary
		
		var body = Data()
		body.append(boundaryPrefix)
		body.append(params.buildHttpBodyPart(boundary: boundary)) // Request Body 추가
		body.append(multiparts
			.map { (multipart: MultipartData) -> Data in
				return multipart.buildHttpBodyPart(boundary: boundary) // Multipart Data 추가
			}
			.reduce(Data.init(), +))
		body.append(boundarySuffix)
		return body as Data // Multipart Data를 포함한 Request Body 반환
	}
	
}
