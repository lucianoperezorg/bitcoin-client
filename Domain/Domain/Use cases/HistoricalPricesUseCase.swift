//
//  HistoricalPricesUseCase.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation
import HTTPNetwork

public typealias HistoricalPricesResult = Swift.Result<[HistoricalPrice], Error>
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
        client.get(from: url) { result in
            switch result {
            case let .success((data, _)):
                do {
                    let remotePrices = try JSONDecoder().decode(RemotePrices.self, from: data)
                    var BitcoinPrices = remotePrices.prices.map {
                        let timeIntervalValue = Double($0[0])
                        let dateVal = TimeInterval(timeIntervalValue / 1000.0)
                        let date = Date(timeIntervalSince1970: TimeInterval(dateVal))
                        return HistoricalPrice(price: $0[1], currency: .EUR, date: date)
                    }
                    BitcoinPrices = BitcoinPrices.dropLast().sorted(by: { $0.date > $1.date })
                    completion(.success(BitcoinPrices))
                } catch  {
                    print(error)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
   
}

//TODO: move this from here
private struct RemotePrices: Decodable {
    let prices: [[Double]]
}
