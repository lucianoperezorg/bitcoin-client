//
//  CurrentPriceUseCase.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation
import HTTPNetwork


public enum Currency: String {
    case EUR, USD,GBP
    
    public var description: String {
        switch self {
        case .EUR: return "EUR"
        case .USD: return "USD"
        case .GBP: return "GBP"
        }
    }
}

public struct Price {
    public let price: Double
    public let currency: Currency
}
 
private struct Bitcon: Decodable {
    let bitcoin: Price2
}

public struct Price2: Decodable {
    public let current: Double
    
    enum CodingKeys: String, CodingKey {
        case current = "eur"
    }
}

public struct CurrentPrice {}
public typealias CurrentPriceResult = Swift.Result<Price, Error>
public protocol CurrentPriceUseCaseType {
    func load(completion: @escaping (CurrentPriceResult) -> Void)
}


public final class CurrentPriceUseCase: CurrentPriceUseCaseType {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
  
    public func load(completion: @escaping (CurrentPriceResult) -> Void) {
        let urlRequest = URLRequest(url: url)
        client.get(from: urlRequest) { result in
            switch result {
            case let .success(data, _):
                do {
                    let d = try? JSONDecoder().decode(Bitcon.self, from: data)
                    let price = Price(price: d!.bitcoin.current, currency: .EUR)
                    completion(.success(price))
                } catch {}
            case .failure:
                break
            }
            
        }
    }
    
    
}
