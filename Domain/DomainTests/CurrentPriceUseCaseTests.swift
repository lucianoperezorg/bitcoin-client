//
//  CurrentPriceUseCaseTests.swift
//  DomainTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation
import XCTest
import Domain
import HTTPNetwork

final class CurrentPriceUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = anyUrl()
        let (sut, client) = makeSUT(url: url)
        
        sut.startObserving()
        
        XCTAssertEqual(client.requestURLs, [url])
        sut.stopObserving()
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()
        expect(sut: sut, toCompleteWith: .failure(PriceError.invalidData), when: {
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples =  [199,201,300,400,500]
    
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: .failure(PriceError.invalidData), when: {
              let json = makeCurrentPriceJSON()
              client.complete(withStatusCode: code,data: json, index: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidaJSON() {
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: .failure(PriceError.dataCorrupted), when: {
            client.complete(withStatusCode: 200, data: anyInvalidData)
        })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithCorrectJSONList() {
        let (sut, client) = makeSUT()
        let priceValue = 234.0
        let givenPrice = Price(value: priceValue, currency: .EUR)
        let emptyList = makeCurrentPriceJSON(priceValue)
        expect(sut: sut, toCompleteWith: .success(givenPrice), when: {
            client.complete(withStatusCode: 200, data: emptyList)
        })
    }
    
    func test_init_doesNotRequestDataAfterStopObservingValues() {
        let client = HTTClientMock()
        let scheduler = SchedulerTimer(frecuency: 1, repeats: true)
       
        let sut = CurrentPriceUseCase(url: anyUrl(), client: client, schedulerTimer: scheduler)
        sut.startObserving()
        
        wait(timeout: 1.0, then: {
            sut.stopObserving()
            XCTAssert(client.getMethodCalled == 2)
        })
        wait(timeout: 1.0, then: {
            XCTAssert(client.getMethodCalled == 2)
        })
    }

    //MARKS: - helper
    
    private func wait(timeout: TimeInterval, then action: @escaping () -> Void) {
        let exp = expectation(description: "Wait expectation for some time")
        let result = XCTWaiter.wait(for: [exp], timeout: timeout)

        if result == XCTWaiter.Result.timedOut {
            action()
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    private func makeCurrentPriceJSON(_ price: Double = 2.3) -> Data {
        let eur =  ["eur": price]
        let pricesJSON = ["bitcoin": eur]
        return try! JSONSerialization.data(withJSONObject: pricesJSON)
    }
    
    private func makeSUT(url: URL = URL(string: "http://an-url.com")!, frecuency: TimeInterval = 0, repets: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (CurrentPriceUseCase, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let scheduler = SchedulerTimer(frecuency: frecuency, repeats: repets)
        
        let sut = CurrentPriceUseCase(url: url, client: client, schedulerTimer: scheduler)
        return (sut, client)
    }
    
    private func expect(sut: CurrentPriceUseCase, toCompleteWith expectedResult: CurrentPriceResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        sut.startObserving()
        let exp = expectation(description: "Wait to load completion")
        sut.priceResultHandler =  { receiveResult in
            switch (receiveResult, expectedResult) {
            case let (.success(receivePrice), .success(expectedPrice)):
                XCTAssertEqual(receivePrice, expectedPrice, file: file, line: line)
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

private class HTTClientMock: HTTPClient {
    var getMethodCalled = 0
    func get(from url: URL, completion: @escaping (HTTPNetwork.HTTPClientResult) -> Void) {
        getMethodCalled += 1
    }
}
