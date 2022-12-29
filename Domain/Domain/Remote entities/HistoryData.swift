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
    
    enum DecodingError: Error {
        case corruptedData
    }
    
    struct Prices: Decodable {
        let values: [String: Double]?
    
        init(from decoder: Decoder) throws {
            let singleValueContainer = try decoder.singleValueContainer()
            let currencyValues = try singleValueContainer.decode([String: Double].self)
            
            guard currencyValues.count > 0 else {
                throw DecodingError.corruptedData
            }
            self.values = currencyValues
        }
        
    }
}
