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
            case let .success((data, _)):
                do {
                    let marketData = try JSONDecoder().decode(MarketData.self, from: data)
                    let usd = Price(price: marketData.currentPrice.prices.usd, currency: .USD)
                    let eur = Price(price: marketData.currentPrice.prices.eur, currency: .EUR)
                    let gbp = Price(price: marketData.currentPrice.prices.gbp, currency: .GBP)
                    let prices = [usd, eur, gbp]
                    completion(.success(prices))
        
                } catch {}
                
            case .failure(let error):
                completion(.failure(error))
            }
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
}
