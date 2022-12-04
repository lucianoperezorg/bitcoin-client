//
//  HTTPClient.swift
//  HTTPNetwork
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
