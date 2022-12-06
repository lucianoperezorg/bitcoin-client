//
//  Currency.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public enum Currency: String {
    case EUR, USD, GBP
    
    public var description: String {
        switch self {
        case .EUR: return "eur"
        case .USD: return "usd"
        case .GBP: return "gbp"
        }
    }
    
    public var icon: String {
        switch self {
        case .EUR: return "🇪🇺"
        case .USD: return "🇺🇸"
        case .GBP: return "🇬🇧"
        }
    }
}
