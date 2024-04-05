# DeclarativeConnectKit

 UI영역에서 SwiftUI로 변경하면서 선언적 형태로 프로젝트가 변경 되는 과정에서 동질성을 위하여 네트워크 부분도 선언적 형태로 만들어 보았다.

 전송 형태 부터 방식, 내용을 선언하고 네트워크 서비스에 dispatch하면 결과를 Combine또는 async/await 형태로 반환 한다.

 UI도 NETWORK도 선언형으로 사용자는 그저 필요한 것을 선언할 뿐.  Thats all!

## Overview

DeclarativeConnectKit is a Swift library designed to simplify network requests with a declarative approach. It leverages Combine and async/await functionalities for efficient and concise networking code.

DeclarativeConnectKit is a networking library written in a declarative manner (like SwiftUI). This library is written in Swift and handles network requests using Combine and the new async/await pattern in Swift 5.5.


## Requirements

- iOS 15.0 or later
- macOS 10.15 or later
- Swift 5.5 or later


## Features

Declarative API: Define your requests in a clear and concise manner using the DCRequest protocol.
Combine & Async/Await Support: Choose between using Combine publishers or async/await syntax for network calls.
Type Safety: Benefit from type safety with Codable models for request and response data.
Error Handling: Handle various network errors through the NetworkRequestError enum.
Logging: Utilize the built-in DCLogger for logging request and response details.
URLRequest to cURL Conversion: Easily convert URLRequests to cURL commands for debugging and sharing.


## Implementation

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

## Usage

### Installation

Swift Package Manager: Add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/your-username/DeclarativeConnectKit.git", .upToNextMajor(from: "1.0.0"))
]
```

Manually: Download the source files and include them in your project.


### Defining Requests

Create a struct conforming to the DCRequest protocol:

```swift
struct GetUsersRequest: DCRequest {
    typealias ReturnType = [User]
    
    var path: String = "/users"
}
```

(Optional) Customize request properties:

```swift
struct CreatePostRequest: DCRequest {
    typealias ReturnType = Post
    
    var path: String = "/posts"
    var method: HTTPMethod = .post
    var body: Params = ["title": "My Post", "content": "Hello world!"]
}


or 

struct BodyParam: Encodable, CustomStringConvertible {
	let title: String
	let content: String

	var description: String {
		return "title: \(title), content: \(content)"
	}
}

struct CreatePostRequest: DCRequest {
    typealias ReturnType = Post
    
    var path: String = "/posts"
    var method: HTTPMethod = .post
    var body: Params = BodyParam(title: "My Post", content: "Hello, World").asParams()
}


```

### Making Requests

#### Using Combine
Create a DeclarativeConnectKit instance with your base URL:

```swift
let connectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")
```

Use the dispatch method with your request:
```swift
connectKit.dispatch(GetUsersRequest())
    .sink(receiveCompletion: { completion in
        // Handle completion (finished or failed)
    }, receiveValue: { users in
        // Process the received users
    })
    .store(in: &cancellables)
```

#### Using Async/Await
Use the async dispatch method:
```swift
do {
    let users = try await connectKit.dispatch(GetUsersRequest())
    // Process the received users
} catch {
    // Handle errors
}
```

#### Logging
The DCLogger automatically logs requests and responses based on the configured log level. You can adjust the log level in the DeclarativeConnectKit initializer:

```swift
let connectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")
connectKit.logger.logLevel = .debug // Set log level to debug
```

## Example

Here's a more complete example demonstrating how to fetch a list of users and create a new post:

```swift
// User model
struct User: Codable {
    let id: Int
    let name: String
}

// Post model
struct Post: Codable {
    let id: Int
    let title: String
    let content: String
}

// Get users request
struct GetUsersRequest: DCRequest {
    typealias ReturnType = [User]
    
    var path: String = "/users"
}

// Create post request
struct CreatePostRequest: DCRequest {
    typealias ReturnType = Post
    
    var path: String = "/posts"
    var method: HTTPMethod = .post
    var body: Params
    
    init(title: String, content: String) {
        self.body = ["title": title, "content": content]
    }
}

// Usage
let connectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")

// Fetch users using Combine
connectKit.dispatch(GetUsersRequest())
    .sink(receiveCompletion: { completion in
        // Handle completion
    }, receiveValue: { users in
        // Process users
        print("Received users: \(users)")
    })
    .store(in: &cancellables)

// Create a post using async/await
do {
    let newPost = try await connectKit.dispatch(CreatePostRequest(title: "New Post", content: "This is a new post!"))
    print("Created post: \(newPost)")
} catch {
    print("Error creating post: \(error)")
}
```


## Error Handling

Handle network request errors using the `NetworkRequestError` enumeration. Each case represents an error according to the HTTP status code.

Here is a description of each error status:

- invalidRequest: This error occurs when the client sends an incorrect request. For example, this error can occur if parameters required for the request are missing or the request format is incorrect.

- badRequest: This error occurs when the server cannot understand the client's request. For example, this error can occur if the syntax of the request is incorrect or the request contains invalid data.

- unauthorized: This error occurs when the client is not authenticated. For example, this error can occur if the client provides incorrect credentials or does not provide any credentials at all.

- forbidden: This error occurs when the client does not have permission for the requested resource. This error can occur if the client is authenticated but does not have permission to access the resource.

- notFound: This error occurs when the server cannot find the resource requested by the client. For example, this error can occur if the URL requested by the client does not exist.

- error4xx: This error represents a 4xx HTTP status code indicating that the client's request is incorrect. This category includes badRequest, unauthorized, forbidden, notFound, etc. described above.

- serverError: This error indicates that there was a problem on the server. This error can occur if an unexpected error occurs while the server is processing the request.

- serviceError: This error indicates that there was a service-related problem on the server. For example, this error can occur if there is a problem with the server's database.

- error5xx: This error represents a 5xx HTTP status code indicating that there was a problem on the server. This category includes serverError, serviceError, etc. described above.

- decodingError: This error indicates that there was a problem decoding the data. For example, this error can occur if there is a problem converting the response from the server into a format that the app can understand.

- urlSessionFailed: This error indicates that the URL session operation failed. For example, this error can occur if the URL session operation is not completed due to network connection problems or other system-level problems.

- unknownError: This error indicates that an unknown error has occurred. This error generally occurs in unexpected situations or unhandled exception situations.



# DeclarativeConnectKit

UI 영역에서 SwiftUI로 변경되면서 프로젝트의 선언적 형태가 증가하는 과정에서 네트워크 부분도 선언적 형태로 만들어졌습니다. 

전송 형태부터 방식, 내용을 선언하고 네트워크 서비스에 dispatch하면 결과를 Combine 또는 async/await 형태로 반환합니다. 

UI와 NETWORK 모두 선언형으로 사용자는 필요한 것을 단순히 선언할 뿐입니다. 그게 전부입니다!

## 개요

DeclarativeConnectKit은 선언적 접근 방식으로 네트워크 요청을 간편하게 하는 Swift 라이브러리입니다. 효율적이고 간결한 네트워킹 코드를 위해 Combine과 async/await 기능을 활용합니다.

DeclarativeConnectKit은 SwiftUI와 같이 선언적 형태로 작성된 네트워킹 라이브러리입니다. Swift로 작성되었으며 Combine 및 Swift 5.5의 새로운 async/await 패턴을 사용하여 네트워크 요청을 처리합니다.

## 요구 사항

- iOS 15.0 이상
- macOS 10.15 이상
- Swift 5.5 이상

## 특징

- 선언적 API: DCRequest 프로토콜을 사용하여 요청을 명확하고 간결하게 정의합니다.
- Combine 및 Async/Await 지원: 네트워크 호출에 Combine 퍼블리셔 또는 async/await 구문을 선택할 수 있습니다.
- 타입 안전성: Codable 모델을 사용하여 요청 및 응답 데이터에 대한 타입 안전성을 제공합니다.
- 오류 처리: NetworkRequestError 열거형을 통해 다양한 네트워크 오류를 처리합니다.
- 로깅: 내장된 DCLogger를 사용하여 요청 및 응답 세부 정보를 로깅합니다.
- URLRequest를 cURL로 변환: URLRequests를 디버깅 및 공유하기 위해 쉽게 cURL 명령으로 변환합니다.

## 구현

DCRequest 프로토콜과 함께 사용할 네트워크 함수를 명시적으로 만듭니다.

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

## 사용 방법

### 설치

Swift Package Manager: Package.swift 파일에 다음을 추가합니다:
```swift
dependencies: [
    .package(url: "https://github.com/your-username/DeclarativeConnectKit.git", .upToNextMajor(from: "1.0.0"))
]
```

수동으로: 소스 파일을 다운로드하고 프로젝트에 포함시킵니다.

### 요청 정의

DCRequest 프로토콜을 준수하는 구조체를 생성합니다:
```swift
struct GetUsersRequest: DCRequest {
    typealias ReturnType = [User]
    
    var path: String = "/users"
}
```

(선택 사항) 요청 속성을 사용자 정의합니다:
```swift
struct CreatePostRequest: DCRequest {
    typealias ReturnType = Post
    
    var path: String = "/posts"
    var method: HTTPMethod = .post
    var body: Params = ["title": "My Post", "content": "Hello world!"]
}

or 

struct BodyParam: Encodable, CustomStringConvertible {
	let title: String
	let content: String

	var description: String {
		return "title: \(title), content: \(content)"
	}
}

struct CreatePostRequest: DCRequest {
    typealias ReturnType = Post
    
    var path: String = "/posts"
    var method: HTTPMethod = .post
    var body: Params = BodyParam(title: "My Post", content: "Hello, World").asParams()
}


```

### 요청 보내기

#### Combine 사용
베이스 URL과 함께 DeclarativeConnectKit 인스턴스를 생성합니다:
```swift
let connectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")
```

요청과 함께 dispatch 메서드를 사용합니다:
```swift
connectKit.dispatch(GetUsersRequest())
    .sink(receiveCompletion: { completion in
        // 완료 처리 (완료되거나 실패)
    }, receiveValue: { users in
        // 받은 사용자 처리
    })
    .store(in: &cancell

ables)
```

#### Async/Await 사용
async dispatch 메서드를 사용합니다:
```swift
do {
    let users = try await connectKit.dispatch(GetUsersRequest())
    // 받은 사용자 처리
} catch {
    // 오류 처리
}
```

#### 로깅
DCLogger는 설정된 로그 수준을 기반으로 요청 및 응답을 자동으로 기록합니다. DeclarativeConnectKit 이니셜라이저에서 로그 수준을 조정할 수 있습니다:
```swift
let connectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")
connectKit.logger.logLevel = .debug // 로그 수준을 디버그로 설정합니다.
```

## 예시

다음은 사용자 목록을 가져오고 새 게시물을 만드는 방법을 보여주는 더 완벽한 예시입니다:
```swift
// 사용자 모델
struct User: Codable {
    let id: Int
    let name: String
}

// 게시물 모델
struct Post: Codable {
    let id: Int
    let title: String
    let content: String
}

// 사용자 목록 가져오기 요청
struct GetUsersRequest: DCRequest {
    typealias ReturnType = [User]
    
    var path: String = "/users"
}

// 게시물 만들기 요청
struct CreatePostRequest: DCRequest {
    typealias ReturnType = Post
    
    var path: String = "/posts"
    var method: HTTPMethod = .post
    var body: Params
    
    init(title: String, content: String) {
        self.body = ["title": title, "content": content]
    }
}

// 사용법
let connectKit = DeclarativeConnectKit(baseURL: "https://api.example.com")

// Combine을 사용하여 사용자 가져오기
connectKit.dispatch(GetUsersRequest())
    .sink(receiveCompletion: { completion in
        // 완료 처리
    }, receiveValue: { users in
        // 사용자 처리
        print("받은 사용자: \(users)")
    })
    .store(in: &cancellables)

// Async/Await을 사용하여 게시물 만들기
do {
    let newPost = try await connectKit.dispatch(CreatePostRequest(title: "새 게시물", content: "이것은 새 게시물입니다!"))
    print("생성된 게시물: \(newPost)")
} catch {
    print("게시물 생성 오류: \(error)")
}
```

## 오류 처리

네트워크 요청 오류는 `NetworkRequestError` 열거형을 사용하여 처리합니다. 각 case는 HTTP 상태 코드에 따른 오류를 나타냅니다. 아래는 각 오류 상태에 대한 설명입니다:

- invalidRequest: 클라이언트가 잘못된 요청을 보낼 때 발생하는 오류입니다. 예를 들어, 요청에 필요한 매개변수가 누락되었거나 요청 형식이 잘못된 경우에 발생할 수 있습니다.

- badRequest: 서버가 클라이언트의 요청을 이해할 수 없는 경우 발생하는 오류입니다. 예를 들어, 요청의 구문이 잘못되었거나 요청에 유효하지 않은 데이터가 포함된 경우에 발생할 수 있습니다.

- unauthorized: 클라이언트가 인증되지 않은 경우 발생하는 오류입니다. 예를 들어, 클라이언트가 잘못된 자격 증명을 제공하거나 전혀 자격 증명을 제공하지 않은 경우에 발생할 수 있습니다.

- forbidden: 클라이언트가 요청한 리소스에 대한 권한이 없는 경우 발생하는 오류입니다. 예를 들어, 클라이언트가 인증되었지만 리소스에 액세스할 수 있는 권한이 없는 경우에 발생할 수 있습니다.

- notFound: 서버가 클라이언트가 요청한 리소스를 찾을 수 없는 경우 발생하는 오류입니다. 예를 들어, 클라이언트가 요청한 URL이 존재하지 않는 경우에 발생할 수 있습니다.

- error4xx: 클라이언트의 요청이 잘못된 경우를 나타내는 4xx HTTP 상태 코드의 오류입니다. 이 카테고리에는 위에서 설명한 badRequest, unauthorized, forbidden, notFound 등이 포함됩니다.

- serverError: 서버에서 문제가 발생한 경우 발생하는 오류입니다. 예를 들어, 서버가 요청을 처리하는 동안 예기치 않은 오류가 발생한 경우에 발생할 수 있습니다.

- serviceError: 서버와 관련된 서비스 문제가 발생한 경우 발생하는 오류입니다. 예를 들어, 서버의 데이터베이스에 문제가 있는 경우 발생할 수 있습니다.

- error5xx: 서버에서 문제가 발생한 것을 나타내는 5xx HTTP 상태 코드의 오류입니다. 이 카테고리에는 위에서 설명한 serverError, serviceError 등이 포함됩니다.

- decodingError: 데이터를 디코딩하는 동안 문제가 발생한 경우 발생하는 오류입니다. 예를 들어, 서버의 응답을 앱이 이해할 수 있는 형식으로 변환하는 동안 문제가 발생하는 경우에 발생할 수 있습니다.

- urlSessionFailed: URL 세션 작업이 실패한 경우 발생하는 오류입니다. 예를 들어, 네트워크 연결 문제나 다른 시스템 수준의 문제로 인해 URL 세션 작업이 완료되지 않는 경우에 발생할 수 있습니다.

- unknownError: 알 수 없는 오류가 발생한 경우입니다. 이 오류는 일반적으로 예상치 못한 상황이나 처리되지 않은 예외 상황에서 발생합니다.


# ???

 버그를 찾거나 궁금증이 있으면 메세지 남겨 주세요. 
