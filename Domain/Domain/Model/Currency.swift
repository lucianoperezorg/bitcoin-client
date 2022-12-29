//
//  Currency.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public enum Currency: String, CaseIterable {
    case USD = "usd", EUR = "eur", GBP = "gbp", ARS = "ars", MX = "mxn", JPY = "jpy"

    public var icon: String {
        switch self {
        case .EUR: return "🇪🇺"
        case .USD: return "🇺🇸"
        case .GBP: return "🇬🇧"
        case .ARS: return "🇦🇷"
        default: return "🏳️"
        }
    }
}
