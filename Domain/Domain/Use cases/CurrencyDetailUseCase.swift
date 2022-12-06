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
        var prices = [Price]()
        if let usd = currentPrice.prices.usd {
            let usdPrice = Price(value: usd, currency: .USD)
            prices.append(usdPrice)
        }
        
        if let eur = currentPrice.prices.eur {
            let eurPrice = Price(value: eur, currency: .EUR)
            prices.append(eurPrice)
        }
        
        if let gbp = currentPrice.prices.gbp {
            let gbpPrice = Price(value: gbp, currency: .GBP)
            prices.append(gbpPrice)
        }
        return prices
    }
}
