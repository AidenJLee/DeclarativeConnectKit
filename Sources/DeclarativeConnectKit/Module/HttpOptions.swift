//  Created by AidenJLee on 2023/03/25.
//

import Foundation
// Params 타입은 [String: CustomStringConvertible] 타입의 typealias로 정의됩니다.
public typealias Params = [String: CustomStringConvertible]

// HTTPParams 타입은 [String: Any] 타입의 typealias로 정의됩니다.
public typealias HTTPParams = [String: Any]

// HTTPHeaders 타입은 [String: String] 타입의 typealias로 정의됩니다.
public typealias HTTPHeaders = [String: String]

// HTTPContentType 열거형은 String rawValue를 가지며, 각 케이스는 HTTP 요청의 Content-Type을 나타냅니다.
public enum HTTPContentType: String {
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
    case multipart = "multipart/form-data"
}

// HTTPHeaderField 열거형은 String rawValue를 가지며, 각 케이스는 HTTP 요청의 헤더 필드를 나타냅니다.
public enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case authToken = "X-AUTH-TOKEN"
    case acceptEncoding = "Accept-Encoding"
}

// HTTPMethod 구조체는 String rawValue를 가지며, HTTP 요청의 메소드를 나타냅니다.
public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    
    public static let get = HTTPMethod(rawValue: "GET")         // `GET` 메소드.
    public static let post = HTTPMethod(rawValue: "POST")       // `POST` 메소드.
    public static let put = HTTPMethod(rawValue: "PUT")         // `PUT` 메소드.
    public static let delete = HTTPMethod(rawValue: "DELETE")   // `DELETE` 메소드.
    
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// HttpBodyConvertible 프로토콜은 HTTP 요청의 Body를 생성하는 메소드를 가지고 있습니다.
public protocol HttpBodyConvertible {
    func buildHttpBodyPart(boundary: String) -> Data
}

// MultipartData 구조체는 HTTP 요청의 Body에 포함될 멀티파트 데이터를 나타냅니다.
public struct MultipartData {
    let name: String
    let fileData: Data
    let fileName: String
    let mimeType: String

    public init(name: String, fileData: Data, fileName: String, mimeType: String) {
        self.name = name
        self.fileData = fileData
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

// HttpBodyConvertible 프로토콜을 채택한 MultipartData 구조체는 buildHttpBodyPart 메소드를 구현합니다.
extension MultipartData: HttpBodyConvertible {
    public func buildHttpBodyPart(boundary: String) -> Data {
        let httpBody = NSMutableData()
        httpBody.appendString("--\(boundary)\r\n")
        httpBody.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        httpBody.appendString("Content-Type: \(mimeType)\r\n\r\n")
        httpBody.append(fileData)
        httpBody.appendString("\r\n")
        return httpBody as Data
    }
}

// Params 타입에 asPercentEncodedString 메소드를 추가합니다.
extension Params {
    public func asPercentEncodedString(parentKey: String? = nil) -> String {
        return self.map { key, value in
            var escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            if let `parentKey` = parentKey {
                escapedKey = "\(parentKey)[\(escapedKey)]"
            }

            if let dict = value as? Params {
                return dict.asPercentEncodedString(parentKey: escapedKey)
            } else if let array = value as? [CustomStringConvertible] {
                return array.map { entry in
                    let escapedValue = "\(entry)"
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                    return "\(escapedKey)[]=\(escapedValue)"
                }.joined(separator: "&")
            } else {
                let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                return "\(escapedKey)=\(escapedValue)"
            }
        }
        .joined(separator: "&")
    }
}

// HttpBodyConvertible 프로토콜을 채택한 Params 타입은 buildHttpBodyPart 메소드를 구현합니다.
extension Params: HttpBodyConvertible {
    public func buildHttpBodyPart(boundary: String) -> Data {
        let httpBody = NSMutableData()
        forEach { (name, value) in
            httpBody.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            httpBody.appendString("\(value)")
            httpBody.appendString("\r\n")
        }
        return httpBody as Data
    }
}

// URL 쿼리 문자열에 포함될 수 없는 문자를 인코딩하기 위한 CharacterSet을 정의합니다.
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

// NSMutableData에 appendString 메소드를 추가합니다.
internal extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
