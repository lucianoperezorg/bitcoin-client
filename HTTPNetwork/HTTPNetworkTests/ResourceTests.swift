//
//  ResourceTests.swift
//  HTTPNetworkTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import XCTest
import HTTPNetwork

final class ResourceTests: XCTestCase {
    func test_init_resolveURLReturnGivenURL() {
        let sut = Resource(url: anyUrl())
        XCTAssertEqual(sut.resolveUrl?.absoluteString, "http://a-given-url.com")
    }
    
    func test_init_resolveURLReturnGivenURLWithParameters() {
        let sut = Resource(url: anyUrl(), parameters: ["test":"value"])
        XCTAssertEqual(sut.resolveUrl?.absoluteString, "http://a-given-url.com?test=value")
    }
}
