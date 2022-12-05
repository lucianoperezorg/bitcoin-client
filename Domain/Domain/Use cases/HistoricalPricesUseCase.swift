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
    
    //TODO: move this from here
    private  var OK_200: Int { return 200 }
    public func load(completion: @escaping (HistoricalPricesResult) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == self.OK_200 else {  return completion(.failure(PriceError.invalidData)) }
                try? completion(HistoricalPricesUseCase.map(data, response: response))
            case .failure:
                completion(.failure(PriceError.invalidData))
            }
        }
    }
}

private extension HistoricalPricesUseCase {
    static func map(_ data: Data, response: HTTPURLResponse) throws -> HistoricalPricesResult {
        do {
            let remotePrices = try JSONDecoder().decode(RemotePrices.self, from: data)
            let models = remotePrices.toModel().filter { !Calendar.current.isDateInToday($0.date) }
            return .success(models)
        } catch  {
            return .failure(PriceError.dataCorrupted)
        }
    }
}

public enum PriceError: Error, Equatable {
    case invalidData
    case dataCorrupted
}

private extension RemotePrices {
    func toModel() -> [HistoricalPrice] {
        let prices: [HistoricalPrice?] = self.prices.compactMap {
            guard let timeIntervalValue = $0.first,
                  let price = $0[safe: 1] else { return nil }
        
            let dateTimeInterval = TimeInterval(timeIntervalValue / 1000.0)
            let date = Date(timeIntervalSince1970: TimeInterval(dateTimeInterval))
            return HistoricalPrice(price: price, currency: .EUR, date: date)
        }
        return prices.compactMap{ $0 }
    }
}

