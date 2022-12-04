//
//  HistoricalPriceLoader.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

public struct CurrencyDetail {}
public typealias CurrencyDetailResult = Swift.Result<[CurrencyDetail], Error>
public protocol CurrencyDetailUseCaseType {
    func currencyDetail(with date: Date, completion: @escaping (CurrencyDetailResult) -> Void)
}
