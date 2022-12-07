//
//  Resource+Price.swift
//  Domain
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation
import HTTPNetwork

public extension Resource {

    static var historicalPrices: Resource {
        let parameters: [String : CustomStringConvertible] = [
            "vs_currency": "eur",
            "days": "\(Config.HISTORICAL_AMOUNT_DAYS))",
            "interval": "daily"
            ]
        return Resource(url: ApiConstants.historicalURL, parameters: parameters)
    }
    
    static var currentPrice: Resource {
        let parameters: [String : CustomStringConvertible] = [
            "ids": "bitcoin",
            "vs_currencies": "eur"
            ]
        return Resource(url: ApiConstants.currentPriceURL, parameters: parameters)
    }
    
    static func PricesDetail(dateString: String) -> Resource {
        let parameters: [String : CustomStringConvertible] = [
            "date": dateString
            ]
        return Resource(url: ApiConstants.detailPriceURL, parameters: parameters)
    }
}
