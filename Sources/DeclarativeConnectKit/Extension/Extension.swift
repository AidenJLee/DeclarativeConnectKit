//  Created by AidenJLee on 2023/03/25.
//

import Foundation

// Encodable 프로토콜을 확장하여 asDictionary라는 변수를 추가합니다.
public extension Encodable {
    var asDictionary: [String: Any] {
        // JSONEncoder를 사용하여 인코딩합니다.
        guard let data: Data = try? JSONEncoder().encode(self) else { return [:] }
        // JSONSerialization을 사용하여 JSON 객체로 변환합니다.
        guard let dictionary: [String : Any] = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return [:] }
        return dictionary
    }
}

// Decodable 프로토콜을 확장하여 fromDictionary라는 함수를 추가합니다.
public extension Decodable {
    static func fromDictionary(from json: Any) -> Self?  {
        // JSONSerialization을 사용하여 JSON 데이터로 변환합니다.
        guard let jsonData: Data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        // JSONDecoder를 사용하여 디코딩합니다.
        return try? JSONDecoder().decode(Self.self, from: jsonData)
    }
}
