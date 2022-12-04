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
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func currencyDetail(completion: @escaping (CurrencyDetailResult) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                completion(CurrencyDetailUseCase.map(data, response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

fileprivate extension CurrencyDetailUseCase {
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> CurrencyDetailResult {
        do {
            let marketData = try JSONDecoder().decode(MarketData.self, from: data)
            return .success(marketData.toModel())
        } catch {
            return .failure(error)
        }
    }
}

private extension MarketData {
    func toModel() -> [Price] {
        let usd = Price(price: self.currentPrice.prices.usd, currency: .USD)
        let eur = Price(price: self.currentPrice.prices.eur, currency: .EUR)
        let gbp = Price(price: self.currentPrice.prices.gbp, currency: .GBP)
        return [usd, eur, gbp]
    }
}




//TODO: move this from here
private struct MarketData : Decodable {
    let currentPrice: CurrentPrice
    
    enum CodingKeys: String, CodingKey {
        case currentPrice = "market_data"
    }
}

private struct CurrentPrice : Decodable {
    let prices: Prices
    
    enum CodingKeys: String, CodingKey {
        case prices = "current_price"
    }
}

private struct Prices: Decodable {
    let usd: Double
    let eur: Double
    let gbp: Double
}
