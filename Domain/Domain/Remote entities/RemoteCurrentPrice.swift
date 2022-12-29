//
//  RemoteCurrentPrice.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

struct RemoteCurrentPrice: Decodable {
    let price: RemotePrice
    
    enum CodingKeys: String, CodingKey {
        case price = "bitcoin"
    }
    
    enum DecodingError: Error {
        case corruptedData
    }
    
    struct RemotePrice: Decodable {
        public var current: Double
        
        init(from decoder: Decoder) throws {
            let singleValueContainer = try decoder.singleValueContainer()
            let currencyValue = try singleValueContainer.decode([String: Double].self)
            guard let price = currencyValue.values.first else {
                throw DecodingError.corruptedData
            }
            self.current = price
        }
    }
}
