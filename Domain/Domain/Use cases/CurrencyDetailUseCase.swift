//
//  CurrencyDetailUseCase.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation
import HTTPNetwork

public typealias CurrencyDetailResult = Swift.Result<[Price], Error>
public protocol CurrencyDetailUseCaseType {
    func currencyDetail(completion: @escaping (CurrencyDetailResult) -> Void)
}

public class CurrencyDetailUseCase: CurrencyDetailUseCaseType {
    
    private let url: URL
    private let client: HTTPClient
    
    private var ok200: Int { return 200 }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func currencyDetail(completion: @escaping (CurrencyDetailResult) -> Void) {
        client.get(from: url) {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                guard response.statusCode == self.ok200 else {  return completion(.failure(PriceError.invalidData)) }
                completion(CurrencyDetailUseCase.map(data, response))
            case .failure:
                completion(.failure(PriceError.invalidData))
            }
        }
    }
}

private extension CurrencyDetailUseCase {
    static func map(_ data: Data, _ response: HTTPURLResponse) -> CurrencyDetailResult {
        do {
            let marketData = try JSONDecoder().decode(HistoryData.self, from: data)
            return .success(marketData.toModel())
        } catch {
            return .failure(PriceError.dataCorrupted)
        }
    }
}

fileprivate extension HistoryData {
    func toModel() -> [Price] {
        var finalPrices = [Price]()
        let prices = currentPrice.prices.values
        let defaultCurrencies = Config.DEFAULT_CURRENCIES_DETAIL
        
        defaultCurrencies.forEach { value in
            if let price = prices?[value.rawValue] {
                guard let currency = Currency(rawValue: value.rawValue) else { return }
                let usdPrice = Price(value: price, currency: currency)
                finalPrices.append(usdPrice)
            }
        }
        return finalPrices
    }
}
