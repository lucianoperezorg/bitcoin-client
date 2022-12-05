//
//  ResourcePriceTests.swift
//  DomainTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import XCTest
import Domain
import HTTPNetwork

final class ResourcePriceTests: XCTestCase {

    func test_currentPriceURL() {
        let resolveCurrentPriceURL = try! XCTUnwrap(Resource.currentPrice.resolveUrl)
        let components = try! XCTUnwrap(URLComponents(url: resolveCurrentPriceURL, resolvingAgainstBaseURL: false))
        let parameters = components.queryItems!.reduce(into: Set<String>()) { $0.insert("\($1.name)=\($1.value!)") }
        
        XCTAssertEqual(components.host, "api.coingecko.com")
        XCTAssertEqual(components.path, "/api/v3/simple/price")
        XCTAssertTrue(parameters.contains("ids=bitcoin"))
        XCTAssertTrue(parameters.contains("vs_currencies=eur"))
    }
   
    func test_historicalPricesURL() {
        let resolveCurrentPriceURL = try! XCTUnwrap(Resource.historicalPrices.resolveUrl)
        let components = try! XCTUnwrap(URLComponents(url: resolveCurrentPriceURL, resolvingAgainstBaseURL: false))
        let parameters = components.queryItems!.reduce(into: Set<String>()) { $0.insert("\($1.name)=\($1.value!)") }
        
        XCTAssertEqual(components.host, "api.coingecko.com")
        XCTAssertEqual(components.path, "/api/v3/coins/bitcoin/market_chart")
        XCTAssertTrue(parameters.contains("days=20"))
        XCTAssertTrue(parameters.contains("interval=daily"))
        XCTAssertTrue(parameters.contains("vs_currency=eur"))
    }
    
    func test_DetailPricesURL() {
        let resolveCurrentPriceURL = try! XCTUnwrap(Resource.PricesDetail(dateString: "2022-12-03").resolveUrl)
        let components = try! XCTUnwrap(URLComponents(url: resolveCurrentPriceURL, resolvingAgainstBaseURL: false))
        let parameters = components.queryItems!.reduce(into: Set<String>()) { $0.insert("\($1.name)=\($1.value!)") }
        
        XCTAssertEqual(components.host, "api.coingecko.com")
        XCTAssertEqual(components.path, "/api/v3/coins/bitcoin/history")
        XCTAssertTrue(parameters.contains("date=2022-12-03"))
    }
}
