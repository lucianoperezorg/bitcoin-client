//
//  HistoricalPrice.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public struct HistoricalPrice: Equatable {
    public let price: Double
    public let currency: Currency
    public let date: Date
    
    public init(price: Double, currency: Currency, date: Date) {
        self.price = price
        self.currency = currency
        self.date = date
    }
}
