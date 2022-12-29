//
//  Config.swift
//  Domain
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation

public struct Config {
    public static var DEFAULT_CURRENCY: Currency { return .EUR }
    public static var HISTORICAL_AMOUNT_DAYS: Int { return 14 }
    public static var CURRENT_PRICE_FRECUENCY_SECONDS: TimeInterval { return 60 }
    public static var DEFAULT_CURRENCIES_DETAIL: [Currency] = [.USD, .EUR, .GBP]
}
