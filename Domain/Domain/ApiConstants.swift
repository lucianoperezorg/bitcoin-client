//
//  ApiConstants.swift
//  Domain
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation

public struct ApiConstants {
    private static let baseURL = URL(string: "https://api.coingecko.com/api/v3")!
    public static let historicalURL = baseURL.appendingPathComponent("/coins/bitcoin/market_chart")
    public static let currentPriceURL = baseURL.appendingPathComponent("/simple/price")
    public static let detailPriceURL = baseURL.appendingPathComponent("/coins/bitcoin/history")
}
