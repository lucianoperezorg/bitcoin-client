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
                
                
                do {
                    let d = try? JSONDecoder().decode(marketData.self, from: data)
                    let miau = Price(price: d!.market_data.current_price.usd, currency: .USD)
                    let miau2 = Price(price: d!.market_data.current_price.eur, currency: .EUR)
                    let miau3 = Price(price: d!.market_data.current_price.gbp, currency: .GBP)
                    let arrayPrices = [miau, miau2,miau3]
                    completion(.success(arrayPrices))
        
                } catch {}
                
            case .failure:
                break
            }
        }
    }
    
    private struct  marketData : Decodable {
        let market_data: CurrentPrice
    }
    
    private struct CurrentPrice : Decodable {
        let current_price: Prices
    }
    
    private struct Prices: Decodable {
        let usd: Double
        let eur: Double
        let gbp: Double
    }
    
    
}
