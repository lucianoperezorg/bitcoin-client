//
//  Price.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public struct Price: Equatable {
    public let value: Double
    public let currency: Currency
    
    public init(value: Double, currency: Currency) {
        self.value = value
        self.currency = currency
    }
}
