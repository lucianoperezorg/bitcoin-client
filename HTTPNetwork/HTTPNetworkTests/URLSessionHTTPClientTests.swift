//
//  URLSessionHTTPClientTests.swift
//  HTTPNetworkTests
//
//  Created by Luciano Perez on 04/12/2022.
//

import XCTest
import HTTPNetwork

final class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
            super.setUp()
            
            URLPrototolStub.startInterceptingRequests()
        }
        
        override func tearDown() {
            super.tearDown()
            URLPrototolStub.stopInterceptingRequests()
        }
        
        func test_getFromUrl_performsGETRequestWithURL() {
            let exp = expectation(description: "Wait for closure to complete")
            let url = anyUrl()
            URLPrototolStub.observeRequest { request in
                XCTAssertEqual(request.url, url)
                XCTAssertEqual(request.httpMethod, "GET")
                exp.fulfill()
            }
            
            URLPrototolStub.stub(url: url, data: nil, response: nil, error: nil)
            let urlRequest = URLRequest(url: url)
            makeSUT().get(from: urlRequest) { _ in }
            
            wait(for: [exp], timeout: 1.0)
        }
        
        func testError() {
            let error = anyNSError()
            let captureError = resultErrorFor(data: nil, response: nil, error: error)
            XCTAssertEqual(error.code, captureError?.code )
        }
        
        func test_getFromURL_failsAllInvalidRepresentationCases() {
            XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
            XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTURLResponse(), error: nil))
            XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
            XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
            XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTURLResponse(), error: anyNSError()))
            XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
            XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTURLResponse(), error: anyNSError()))
            XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
            XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTURLResponse(), error: nil))
        }
        
        func test_getFromURL_succesOnHTTOURLResponse() {
            let givenData = anyData()
            let givenResponse = anyURLResponse()
            let values = resultValuesFor(data: givenData, response: givenResponse)
            XCTAssertEqual(values?.data, givenData)
            XCTAssertEqual(values?.response.url, givenResponse.url)
            XCTAssertEqual(values?.response.statusCode, givenResponse.statusCode)
        }
        
        func test_getFromURL_succesOnHTTOURLResponse2() {
            let givenResponse = anyURLResponse()
            let values = resultValuesFor(data: nil, response: givenResponse)
            let emptyData = Data()
            XCTAssertEqual(values?.data, emptyData)
            XCTAssertEqual(values?.response.url, givenResponse.url)
            XCTAssertEqual(values?.response.statusCode, givenResponse.statusCode)
        }
        
        //MARK: - Helper
        
        func nonHTTURLResponse() -> URLResponse {
            return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        }
        
        func anyURLResponse() -> HTTPURLResponse {
            return HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        }
        
        func anyData() -> Data {
            Data("any data".utf8)
        }
        
        func resultValuesFor(data: Data?, response: URLResponse?, error: NSError? = nil, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
            let result = resultFor(data: data, response: response , error: error)
            var values: (data: Data, response: HTTPURLResponse)?
            switch result {
            case .success((let data, let urlResponse)):
                values = (data, urlResponse)
            default:
                XCTFail("Expected failure, got \(result) instead",  file: file, line: line)
            }
            return values
        }
        
        
        func resultErrorFor(data: Data?, response: URLResponse?, error: NSError? = nil, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
            let result = resultFor(data: data, response: response , error: error)
            var captureError: NSError?
            switch result {
            case .failure(let error):
                captureError = error as NSError
                break
            default:
                XCTFail("Expected failure, got \(result) instead",  file: file, line: line)
            }
            return captureError
        }
        
        func resultFor(data: Data?, response: URLResponse?, error: NSError? = nil, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
            URLPrototolStub.stub(url: anyUrl(), data: data, response: response, error: error)
            
            let exp = expectation(description: "Wait for closure to complete")
            var expectedResult: HTTPClientResult!
            let urlrequest = URLRequest(url: anyUrl())
            makeSUT().get(from: urlrequest) { result in
                expectedResult = result
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
            return expectedResult
        }
        
        func makeSUT() -> HTTPClient {
            let sut = URLSessionHTTPClient()
            return sut
        }
        
        private class URLPrototolStub: URLProtocol {
            private static var stubs: Stub?
            private static var requestObserver: ((URLRequest) -> Void)?
            
            private struct Stub {
                let data: Data?
                let response: URLResponse?
                let error: NSError?
            }
            
            static func observeRequest(observer: @escaping (URLRequest) -> Void) {
                requestObserver = observer
            }
            
            static func startInterceptingRequests() {
                URLProtocol.registerClass(URLPrototolStub.self)
            }
            
            static func stopInterceptingRequests() {
                URLProtocol.unregisterClass(URLPrototolStub.self)
                stubs = nil
                requestObserver = nil
            }
            
            static func stub(url: URL, data: Data?, response: URLResponse?, error: NSError? = nil) {
                stubs = Stub(data: data, response: response, error: error)
            }
            
            override class func canInit(with request: URLRequest) -> Bool {
                return true
            }
            
            override class func canonicalRequest(for request: URLRequest) -> URLRequest {
                requestObserver?(request)
                return request
            }
            
            override func startLoading() {
                if let data = URLPrototolStub.stubs?.data {
                    client?.urlProtocol(self, didLoad: data)
                }
                
                if let response = URLPrototolStub.stubs?.response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let error = URLPrototolStub.stubs?.error {
                    client?.urlProtocol(self, didFailWithError: error)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
            
            override func stopLoading() { }
        }
}
