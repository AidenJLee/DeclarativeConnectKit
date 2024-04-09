// |
//  Created by AidenJLee on 2023/03/25.
//

import Foundation

public enum NetworkingLogLevel {
	case off
	case info
	case debug
}

class DCLogger {
	
	var logLevel: NetworkingLogLevel
	
	init(logLevel: NetworkingLogLevel = .info) {
		self.logLevel = logLevel
	}
	
	// URLRequest를 로깅하는 함수
	func log(request: URLRequest) {
		guard logLevel != .off else {
			return
		}
		if let method = request.httpMethod, let url = request.url {
			print("\(method) '\(url.absoluteString)'")
			logHeaders(request)
			logBody(request)
		}
		if logLevel == .debug {
			print(request.toCurlCommand())
		}
	}
	
	// URLResponse와 Data를 로깅하는 함수
	func log(response: URLResponse, data: Data) {
		guard logLevel != .off else {
			return
		}
		if let response = response as? HTTPURLResponse {
			logStatusCodeAndURL(response)
		}
		if logLevel == .debug {
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
				print(json)
			} catch {
				print("error : ", error.localizedDescription)
			}
		}
	}
	
	// HTTP Header를 로깅하는 함수
	private func logHeaders(_ urlRequest: URLRequest) {
		if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
			allHTTPHeaderFields.forEach { key, value in
				print("\(key) : \(value)")
			}
		}
	}
	
	// HTTP Body를 로깅하는 함수
	private func logBody(_ urlRequest: URLRequest) {
		if let body = urlRequest.httpBody, let str = String(data: body, encoding: .utf8) {
			print("HttpBody : \(str)")
		}
	}
	
	// HTTP Status Code와 URL을 로깅하는 함수
	private func logStatusCodeAndURL(_ urlResponse: HTTPURLResponse) {
		if let url = urlResponse.url {
			print("\(urlResponse.statusCode) '\(url.absoluteString)'")
		}
	}
	
}

extension URLRequest {
	
	/**
	 Heavily inspired from : https://gist.github.com/shaps80/ba6a1e2d477af0383e8f19b87f53661d
	 */
	
	// URLRequest를 cURL command로 변환하는 함수
	public func toCurlCommand() -> String {
		guard let url: URL = url else { return "" }
		var command: [String] = [#"curl "\#(url.absoluteString)""#]
		
		if let httpMethod, httpMethod != "GET", httpMethod != "HEAD" {
			command.append("-X \(httpMethod)")
		}
		
		allHTTPHeaderFields?
			.filter { $0.key != "Cookie" }
			.forEach { key, value in
				command.append("-H '\(key): \(value)'")
			}
		
		if let data = httpBody, let body = String(data: data, encoding: .utf8) {
			command.append("-d '\(body)'")
		}
		
		return command.joined(separator: " \\\n\t")
	}
}
