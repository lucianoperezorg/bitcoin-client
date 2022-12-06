//
//  CurrencyDetailUseCaseTests.swift
//  DomainTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import XCTest
import Domain
import HTTPNetwork

final class CurrencyDetailUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = anyUrl()
        let (sut, client) = makeSUT(url: url)
        
        sut.currencyDetail { _ in }
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = anyUrl()
        let (sut, client) = makeSUT(url: url)
        
        sut.currencyDetail { _ in }
        sut.currencyDetail { _ in }
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(with: anyNSError())
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples =  [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
                let json = makePriceJSON(["any": 23.3])
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
    
    func test_load_deliversPricesOn200HTTPResponseWithValidJSONList() {
        let (sut, client) = makeSUT()
        let prices = makeValidPrices()
        expect(sut: sut, toCompleteWith: .success(prices.model), when: {
            let emptyList = makePriceJSON(prices.json)
            client.complete(withStatusCode: 200, data: emptyList)
        })
    }
    
    func test_load_deliversPricesOn200HTTPResponseWithPartialValidJSON() {
        let (sut, client) = makeSUT()
        
        let partialValidJson = [
            "usd": 224.3,
            "eur": 23324.3,
            "testOther": 3444.4
        ]
        let prices = [
            Price(value: 224.3, currency: .USD),
            Price(value: 23324.3, currency: .EUR),
        ]
        
        expect(sut: sut, toCompleteWith: .success(prices), when: {
            let jsonPrice = makePriceJSON(partialValidJson)
            client.complete(withStatusCode: 200, data: jsonPrice)
        })
    }
    
    func test_load_deliverdsErrorOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let invalidCurrencyJson = ["testOtherCurrency": 3444.4]
        expect(sut: sut, toCompleteWith: .success([]), when: {
            let jsonPrice = makePriceJSON(invalidCurrencyJson)
            client.complete(withStatusCode: 200, data: jsonPrice)
        })
    }
    
    //MARK: helpers
    private func makeValidPrices() -> (json: [String: Any], model: [Price]) {
        let json = [
            "usd": 224.3,
            "eur": 23324.3,
            "gbp": 3324.3,
        ]
        let prices = [Price(value: 224.3, currency: .USD),
                      Price(value: 23324.3, currency: .EUR),
                      Price(value: 3324.3, currency: .GBP)]
        return (json, prices)
    }
    
    private func makePriceJSON(_ currentPrices: [String: Any]) -> Data {
        let currentPrice = ["current_price" : currentPrices ]
        let pricesJSON = ["market_data": currentPrice]
        return try! JSONSerialization.data(withJSONObject: pricesJSON)
    }
    
    private func failure(_ error: PriceError) -> CurrencyDetailResult {
        .failure(error)
    }
    
    private func makeSUT(url: URL = URL(string: "http://an-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (CurrencyDetailUseCase, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = CurrencyDetailUseCase(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(sut: CurrencyDetailUseCase, toCompleteWith expectedResult: CurrencyDetailResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait to load completion")
        sut.currencyDetail { receiveResult in
            switch (receiveResult, expectedResult) {
            case let (.success(receiveCurrentPrice), .success(expectedCurrentPrice)):
                XCTAssertEqual(receiveCurrentPrice, expectedCurrentPrice, file: file, line: line)
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
}
