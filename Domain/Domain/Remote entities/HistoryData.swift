//
//  HistoryData.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

struct HistoryData : Decodable {
    let currentPrice: CurrentPrice
    
    enum CodingKeys: String, CodingKey {
        case currentPrice = "market_data"
    }
    
    struct CurrentPrice : Decodable {
        let prices: Prices
        
        enum CodingKeys: String, CodingKey {
            case prices = "current_price"
        }
    }
    
    struct Prices: Decodable {
        let usd: Double?
        let eur: Double?
        let gbp: Double?
    }
}
