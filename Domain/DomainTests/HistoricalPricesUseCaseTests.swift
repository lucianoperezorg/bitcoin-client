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
            let clientError = anyNSError()
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
      let (sut, client) = makeSUT()
      let samples =  [199, 201, 300, 400, 500]
      
      samples.enumerated().forEach { index, code in
        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
          let json = makePricesJSON([])
          client.complete(withStatusCode: code,data: json, index: index)
        })
      }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidaJSON() {
      let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: failure(.dataCorrupted), when: {
        client.complete(withStatusCode: 200, data: anyInvalidData)
      })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyJSONList() {
      let (sut, client) = makeSUT()
      
      expect(sut: sut, toCompleteWith: .success([]), when: {
        let emptyList = makePricesJSON([])
        client.complete(withStatusCode: 200, data: emptyList)
      })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithValidJSON() {
      let (sut, client) = makeSUT()
    
        let yesterdayDate = Date.yesterday
        let price1 = makePrice(price: 16134.3, date: yesterdayDate)
        let price2 = makePrice(price: 16135.3, date: yesterdayDate)
        
        expect(sut: sut, toCompleteWith: .success([price1.model, price2.model])) {
            let json = makePricesJSON([price1.Json, price2.Json])
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
            let json = makePricesJSON([price1.Json, price2.Json])
        client.complete(withStatusCode: 200, data: json)
      }
    }
    
    //MARK: helpers
    private func makePrice(price: Double, currency: Currency = .EUR ,date: Date) ->
    (model: HistoricalPrice, Json: [Double]) {
        let historicalPrice = HistoricalPrice(price: price, currency: .EUR, date: date)
        let priceJson = [ date.timeIntervalSince1970 * 1000, price]
        return (historicalPrice, priceJson)
    }
    
    private func makePricesJSON(_ prices: [[Double]]) -> Data {
      let pricesJSON = ["prices": prices]
      return try! JSONSerialization.data(withJSONObject: pricesJSON)
    }
    
    private func failure(_ error: PriceError) -> HistoricalPricesResult {
        .failure(error)
    }
    
    private func expect(sut: HistoricalPricesUseCase, toCompleteWith expectedResult: HistoricalPricesResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait to load completion")
        sut.load { receiveResult in
            switch (receiveResult, expectedResult) {
            case let (.success(receiveHistoricalPrice), .success(expectedHistoricalPrice)):
                XCTAssertEqual(receiveHistoricalPrice, expectedHistoricalPrice, file: file, line: line)
            case let (.failure(receivedError), .failure(expectdError)):
                XCTAssertEqual(receivedError as! PriceError, expectdError as! PriceError, file: file, line: line)
       
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
