//
//  HistoricalPricesUseCaseTests.swift
//  DomainTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import XCTest
import Domain
import HTTPNetwork

final class HistoricalPricesUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = anyUrl()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = anyUrl()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
      let (sut, client) = makeSUT()
      let samples =  [199,201,300,400,500]
      
      samples.enumerated().forEach { index, code in
        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
          let json = makeItemJSON([])
          client.complete(withStatusCode: code,data: json, index: index)
        })
      }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidaJSON() {
      let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: failure(.dataCorrupted), when: {
        let invalidData = Data("invalida json".utf8)
        client.complete(withStatusCode: 200, data: invalidData)
      })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyJSONList() {
      let (sut, client) = makeSUT()
      
      expect(sut: sut, toCompleteWith: .success([]), when: {
        let emptyList = makeItemJSON([])
        client.complete(withStatusCode: 200, data: emptyList)
      })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithValidJSON() {
      let (sut, client) = makeSUT()
    
        let yesterdayDate = Date.yesterday
        let price1 = makePrice(price: 16134.3, date: yesterdayDate)
        let price2 = makePrice(price: 16135.3, date: yesterdayDate)
        
        expect(sut: sut, toCompleteWith: .success([price1.model, price2.model])) {
            let json = makeItemJSON([price1.Json, price2.Json])
        client.complete(withStatusCode: 200, data: json)
      }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithValidJSONWithSomePriceWithTodayDate() {
      let (sut, client) = makeSUT()
    
        let yesterdayDate = Date.yesterday
        let todayDate = Date()
        let price1 = makePrice(price: 16134.3, date: yesterdayDate)
        let price2 = makePrice(price: 16135.3, date: todayDate)
        
        expect(sut: sut, toCompleteWith: .success([price1.model])) {
            let json = makeItemJSON([price1.Json, price2.Json])
        client.complete(withStatusCode: 200, data: json)
      }
    }
    //MARK: helpers
    private func makePrice(price: Double, currency: Currency = .EUR ,date: Date) ->
    (model: HistoricalPrice, Json: [Double]) {
        let historicalPrice = HistoricalPrice(price: price, currency: .EUR, date: date)
        let itemJson = [ date.timeIntervalSince1970 * 1000, price]
        return (historicalPrice, itemJson)
    }
    
    private func makeItemJSON(_ items: [[Double]]) -> Data {
      let pricesJSON = ["prices": items]
      return try! JSONSerialization.data(withJSONObject: pricesJSON)
    }
    
    private func failure(_ error: HistoricalPricesError) -> HistoricalPricesResult {
        .failure(error)
    }
    
    private func expect(sut: HistoricalPricesUseCase, toCompleteWith expectedResult: HistoricalPricesResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait to load completion")
        sut.load { receiveResult in
            switch (receiveResult, expectedResult) {
            case let (.success(receiveItems), .success(expectedItems)):
                XCTAssertEqual(receiveItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError), .failure(expectdError)):
                XCTAssertEqual(receivedError as! HistoricalPricesError, expectdError as! HistoricalPricesError, file: file, line: line)
       
            default:
                XCTFail("Expected result \(receiveResult), got \(expectedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(url: URL = URL(string: "http://an-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (HistoricalPricesUseCase, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = HistoricalPricesUseCase(url: url, client: client)
        return (sut, client)
    }
}

class HTTPClientSpy: HTTPClient {

    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    var requestURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPNetwork.HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, index: Int = 0) {
        let response = HTTPURLResponse(url: requestURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        
        messages[index].completion(.success((data, response)))
    }
}


func anyNSError() -> NSError {
    return NSError(domain: "Any error", code: 0)
}

func anyUrl() -> URL {
    URL(string: "http://a-given-url.com")!
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
