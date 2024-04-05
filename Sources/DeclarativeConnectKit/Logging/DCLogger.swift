// |이 코드는 네트워크 로그를 출력하는 클래스인 `DCLogger`와 URLRequest를 cURL 명령어로 변환하는 URLRequest의 확장(extension)이 포함된 파일입니다.
// |
// |좋은 점:
// |- `DCLogger` 클래스는 로그 레벨을 설정할 수 있어서 필요한 정보만 출력할 수 있습니다.
// |- `log(request:)` 함수에서 HTTP 메소드와 URL, 헤더, 바디 등 HTTP 요청 정보를 출력합니다.
// |- `log(response:data:)` 함수에서 HTTP 응답 코드와 URL, 응답 데이터를 출력합니다.
// |- `URLRequest`의 `toCurlCommand()` 함수는 해당 요청을 cURL 명령어로 변환하여 출력할 수 있습니다.
// |
// |아쉬운 점:
// |- `log(request:)` 함수에서 HTTP 요청 바디를 출력할 때, 바디가 JSON 형식이 아닌 경우에는 출력하지 않습니다. 이 경우에도 바디를 출력할 수 있도록 개선할 수 있습니다.
// |- `log(response:data:)` 함수에서 JSON 데이터를 출력할 때, `JSONSerialization`의 `jsonObject(with:options:)` 메소드를 사용하고 있습니다. 이 메소드는 JSON 데이터가 유효하지 않은 경우에 예외를 발생시키므로, 예외 처리를 추가하는 것이 좋습니다. 또한, JSON 데이터가 아닌 경우에 대한 처리도 추가하는 것이 좋습니다.
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
