//
//  TestHelper.swift
//  HTTPNetworkTests
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "Any error", code: 0)
}

func anyUrl() -> URL {
    URL(string: "http://a-given-url.com")!
}
