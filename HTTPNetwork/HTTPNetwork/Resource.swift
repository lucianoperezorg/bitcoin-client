//
//  Resource.swift
//  HTTPNetwork
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation

public struct Resource {
    private let url: URL
    private let parameters: [String: CustomStringConvertible]
    
    public var resolveUrl: URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = parameters.keys.map { key in
            URLQueryItem(name: key, value: parameters[key]?.description)
        }
        guard let url = components.url else {
            return nil
        }
        return url
    }
    

    public init(url: URL, parameters: [String: CustomStringConvertible] = [:]) {
        self.url = url
        self.parameters = parameters
    }
}
