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
    
    struct RemotePrice: Decodable {
        public let current: Double
        
        enum CodingKeys: String, CodingKey {
            case current = "eur"
        }
    }
}
