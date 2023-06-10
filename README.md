# DeclarativeConnectKit

DeclarativeConnectKit is a networking library written in a declarative manner (like SwiftUI). This library is written in Swift and handles network requests using Combine and the new async/await pattern in Swift 5.5.

## Requirements

- iOS 15.0 or later
- macOS 10.15 or later
- Swift 5.5 or later

## Key Features

- Supports HTTP methods (GET, POST, PUT, DELETE, etc.)
- Supports JSON, URL Encoded, Multipart forms of HTTP Body
- Configurable HTTP Header
- Configurable Query Parameter
- Able to transmit Multipart Data
- Configurable authentication token
- Configurable JSON Decoder
- Network request logging feature

## Usage

### Initialization

Create with baseURL included

```swift
let declarativeConnectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")
```

### Implementation

Explicitly create the network function you want to use with a struct along with the DCRequest Protocol.

```swift
struct MyRequest: DCRequest {
    typealias ReturnType = MyResponse
    var path: String { return "/path" }
    var method: HTTPMethod { return .get }
    var contentType: HTTPContentType { return .json }
    var queryParams: HTTPParams? { return ["key": "value"] }
    var body: Params? { return ["key": "value"] }
    var headers: HTTPHeaders? { return ["key": "value"] }
    var multipartData: [MultipartData]? { return [MultipartData(name: "file", fileData: Data(), fileName: "file.txt", mimeType: "text/plain")] }
    var authToken: String? { return "token" }
    var decoder: JSONDecoder? { return JSONDecoder() }
}
```

### Use

Create a Combine publisher by putting the implemented struct, and you can receive the network result value.

```swift
let myRequest = MyRequest()
let publisher: AnyPublisher<MyResponse, NetworkRequestError> = declarativeConnectKit.dispatch(myRequest)
```

Or you can use the async/await pattern. This method is recommended when used with SwiftUI.

```swift
let myRequest = MyRequest()
let response: MyResponse = try await declarativeConnectKit.dispatch(myRequest)
```



## Error Handling

Handle network request errors using the `NetworkRequestError` enumeration. Each case represents an error according to the HTTP status code.

Here is a description of each error status:

invalidRequest: This error occurs when the client sends an incorrect request. For example, this error can occur if parameters required for the request are missing or the request format is incorrect.

badRequest: This error occurs when the server cannot understand the client's request. For example, this error can occur if the syntax of the request is incorrect or the request contains invalid data.

unauthorized: This error occurs when the client is not authenticated. For example, this error can occur if the client provides incorrect credentials or does not provide any credentials at all.

forbidden: This error occurs when the client does not have permission for the requested resource. This error can occur if the client is authenticated but does not have permission to access the resource.

notFound: This error occurs when the server cannot find the resource requested by the client. For example, this error can occur if the URL requested by the client does not exist.

error4xx: This error represents a 4xx HTTP status code indicating that the client's request is incorrect. This category includes badRequest, unauthorized, forbidden, notFound, etc. described above.

serverError: This error indicates that there was a problem on the server. This error can occur if an unexpected error occurs while the

server is processing the request.

serviceError: This error indicates that there was a service-related problem on the server. For example, this error can occur if there is a problem with the server's database.

error5xx: This error represents a 5xx HTTP status code indicating that there was a problem on the server. This category includes serverError, serviceError, etc. described above.

decodingError: This error indicates that there was a problem decoding the data. For example, this error can occur if there is a problem converting the response from the server into a format that the app can understand.

urlSessionFailed: This error indicates that the URL session operation failed. For example, this error can occur if the URL session operation is not completed due to network connection problems or other system-level problems.

unknownError: This error indicates that an unknown error has occurred. This error generally occurs in unexpected situations or unhandled exception situations.


## Logging

Use the `DCLogger` class to log network requests and responses. The logging level can be selected from `.off`, `.info`, `.debug`.

In the public struct DCDispatcher, you need to put the level when initializing logging. The default setting is .info.

```swift
private let logger = DCLogger(logLevel: .info)
```

When you raise the level to .debug, you can see the command in curl form in the log.



# DeclarativeConnectKit

DeclarativeConnectKit는 선언적 형태로 작성된 네트워킹 라이브러리입니다. (like SwiftUI)
이 라이브러리는 Swift로 작성되었으며 Combine과 Swift 5.5의 새로운 async/await 패턴을 사용하여 네트워크 요청을 처리합니다.


## 요구 사항

- iOS 15.0 이상
- macOS 10.15 이상
- Swift 5.5 이상


## 주요 기능

- HTTP 메소드(GET, POST, PUT, DELETE 등) 지원
- JSON, URL Encoded, Multipart 형식의 HTTP Body 지원
- HTTP Header 설정 가능
- Query Parameter 설정 가능
- Multipart Data 전송 가능
- 인증 토큰 설정 가능
- JSON Decoder 설정 가능
- 네트워크 요청 로깅 기능

## 사용 방법

### 생성

baseURL을 포함하여 생성

```swift
let declarativeConnectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")
```

### 구현

사용하고자 하는 네트워크 기능을 구조체를 이용하여 DCRequest Protocol과 함께 명시적으로 생성합니다.

```swift
struct MyRequest: DCRequest {
    typealias ReturnType = MyResponse
    var path: String { return "/path" }
    var method: HTTPMethod { return .get }
    var contentType: HTTPContentType { return .json }
    var queryParams: HTTPParams? { return ["key": "value"] }
    var body: Params? { return ["key": "value"] }
    var headers: HTTPHeaders? { return ["key": "value"] }
    var multipartData: [MultipartData]? { return [MultipartData(name: "file", fileData: Data(), fileName: "file.txt", mimeType: "text/plain")] }
    var authToken: String? { return "token" }
    var decoder: JSONDecoder? { return JSONDecoder() }
}
```

### 사용

구현 한 구조체를 담아 Combine publisher을 생성하면 네트워크 결과 값을 받을 수 있습니다.

```swift
let myRequest = MyRequest()
let publisher: AnyPublisher<MyResponse, NetworkRequestError> = declarativeConnectKit.dispatch(myRequest)
```

또는 async/await 패턴을 사용할 수 있습니다. SwiftUI와 함께 사용 할 때는 이 방식을 추천 합니다.

```swift
let myRequest = MyRequest()
let response: MyResponse = try await declarativeConnectKit.dispatch(myRequest)
```



## 에러 처리

`NetworkRequestError` 열거형을 사용하여 네트워크 요청 에러를 처리합니다. 각 케이스는 HTTP 상태 코드에 따른 에러를 나타냅니다.

각 에러 상태에 대한 설명은 다음과 같습니다:

invalidRequest: 이 에러는 클라이언트가 잘못된 요청을 보냈을 때 발생합니다. 예를 들어, 요청에 필요한 매개변수가 누락되었거나, 요청 형식이 잘못된 경우에 이 에러가 발생할 수 있습니다.

badRequest: 이 에러는 서버가 클라이언트의 요청을 이해할 수 없을 때 발생합니다. 예를 들어, 요청의 구문이 잘못되었거나, 요청에 유효하지 않은 데이터가 포함되어 있는 경우에 이 에러가 발생할 수 있습니다.

unauthorized: 이 에러는 클라이언트가 인증되지 않았을 때 발생합니다. 예를 들어, 클라이언트가 잘못된 자격 증명을 제공하거나, 자격 증명을 전혀 제공하지 않은 경우에 이 에러가 발생할 수 있습니다.

forbidden: 이 에러는 클라이언트가 요청한 리소스에 대한 권한이 없을 때 발생합니다. 클라이언트가 인증되었지만, 해당 리소스에 접근할 권한이 없는 경우에 이 에러가 발생할 수 있습니다.

notFound: 이 에러는 클라이언트가 요청한 리소스를 서버에서 찾을 수 없을 때 발생합니다. 예를 들어, 클라이언트가 요청한 URL이 존재하지 않는 경우에 이 에러가 발생할 수 있습니다.

error4xx: 이 에러는 클라이언트의 요청이 잘못되었음을 나타내는 4xx HTTP 상태 코드를 나타냅니다. 이 범주에는 위에서 설명한 badRequest, unauthorized, forbidden, notFound 등이 포함됩니다.

serverError: 이 에러는 서버에서 문제가 발생했음을 나타냅니다. 서버가 요청을 처리하는 도중에 예상치 못한 오류가 발생한 경우에 이 에러가 발생할 수 있습니다.

serviceError: 이 에러는 서버에서 서비스 관련 문제가 발생했음을 나타냅니다. 예를 들어, 서버의 데이터베이스에 문제가 발생한 경우에 이 에러가 발생할 수 있습니다.

error5xx: 이 에러는 서버에서 문제가 발생했음을 나타내는 5xx HTTP 상태 코드를 나타냅니다. 이 범주에는 위에서 설명한 serverError, serviceError 등이 포함됩니다.

decodingError: 이 에러는 데이터를 디코딩하는 도중에 문제가 발생했음을 나타냅니다. 예를 들어, 서버에서 받은 응답을 앱이 이해할 수 있는 형식으로 변환하는 도중에 문제가 발생한 경우에 이 에러가 발생할 수 있습니다.

urlSessionFailed: 이 에러는 URL 세션 작업이 실패했음을 나타냅니다. 예를 들어, 네트워크 연결 문제나 기타 시스템 수준의 문제로 인해 URL 세션 작업이 완료되지 않은 경우에 이 에러가 발생할 수 있습니다.

unknownError: 이 에러는 알 수 없는 오류가 발생했음을 나타냅니다. 이 에러는 일반적으로 예상치 못한 상황이나 처리되지 않은 예외 상황에서 발생합니다.


## 로깅

`DCLogger` 클래스를 사용하여 네트워크 요청과 응답을 로깅합니다. 로깅 레벨은 `.off`, `.info`, `.debug` 중에서 선택할 수 있습니다.

public struct DCDispatcher에서 로깅을 초기 화 할떄 레벨을 넣어주어야 합니가. 기본 설정은 .info입니다.

```swift
private let logger = DCLogger(logLevel: .info)
```

.debug 레벨로 올렸을 경우 로그에서 curl형태로 확인 할 수 있는 명령어를 볼 수 있습니다.
