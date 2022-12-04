//
//  Currency.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public enum Currency: String {
    case EUR, USD,GBP
    
    public var description: String {
        switch self {
        case .EUR: return "EUR"
        case .USD: return "USD"
        case .GBP: return "GBP"
        }
    }
}
