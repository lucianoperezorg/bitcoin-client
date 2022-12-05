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
    
    private  var OK_200: Int { return 200 }
    public func currencyDetail(completion: @escaping (CurrencyDetailResult) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == self.OK_200 else {  return completion(.failure(PriceError.invalidData)) }
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
        let usd = Price(value: self.currentPrice.prices.usd, currency: .USD)
        let eur = Price(value: self.currentPrice.prices.eur, currency: .EUR)
        let gbp = Price(value: self.currentPrice.prices.gbp, currency: .GBP)
        return [usd, eur, gbp]
    }
}
