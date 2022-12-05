//
//  HTTPClientSpy.swift
//  DomainTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation
import Domain
import HTTPNetwork

public class HTTPClientSpy: HTTPClient {

    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    var requestURLs: [URL] {
        return messages.map { $0.url }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPNetwork.HTTPClientResult) -> Void) {
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
