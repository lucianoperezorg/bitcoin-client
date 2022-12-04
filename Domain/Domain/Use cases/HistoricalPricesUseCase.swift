//
//  HistoricalPricesUseCase.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation
import HTTPNetwork

public struct BitcoinPricesModel {
    public let price: Double
    public let currency: Currency
    public let date: Date
}

public typealias HistoricalPricesResult = Swift.Result<[BitcoinPricesModel], Error>
public protocol HistoricalPricesUseCaseType {
    func load(completion: @escaping (HistoricalPricesResult) -> Void)
}

public final class HistoricalPricesUseCase: HistoricalPricesUseCaseType {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (HistoricalPricesResult) -> Void) {
        let urlRequest = URLRequest(url: url)
        client.get(from: urlRequest) { result in
            switch result {
            case let .success((data, _)):
                do {
                    let d = try JSONDecoder().decode(Price.self, from: data)
                    var BitcoinPrices = d.prices.map {
                        let timeIntervalValue = Double($0[0])
                        let dateVal = TimeInterval(timeIntervalValue / 1000.0)
                        let date = Date(timeIntervalSince1970: TimeInterval(dateVal))
                        return BitcoinPricesModel(price: $0[1], currency: .EUR, date: date)
                    }
                    BitcoinPrices = BitcoinPrices.dropLast().sorted(by: { $0.date > $1.date })
                    completion(.success(BitcoinPrices))
                } catch  {
                    print(error)
                }
            case let .failure(_):
                break
            }
        }
    }
    
    private struct Price: Decodable {
        let prices: [[Double]]
    }
}
