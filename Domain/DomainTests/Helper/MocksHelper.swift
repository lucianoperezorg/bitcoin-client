//
//  MocksHelper.swift
//  DomainTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "Any error", code: 0)
}

func anyUrl() -> URL {
    URL(string: "http://a-given-url.com")!
}

var anyInvalidaData: Data {
    Data("invalida json".utf8)
}
