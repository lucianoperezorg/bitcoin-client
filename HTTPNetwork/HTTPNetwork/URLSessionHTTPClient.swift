//
//  URLSessionHTTPClient.swift
//  HTTPNetwork
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesReprestation: Error {}
    
    public func get(from urlRequest: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesReprestation()))
            }
        }.resume()
    }
}
