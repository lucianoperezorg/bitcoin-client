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
    let bitcoin: CurrentPrice
}

public struct CurrentPrice: Decodable {
    public let current: Double
    
    enum CodingKeys: String, CodingKey {
        case current = "eur"
    }
}


public typealias CurrentPriceResult = Swift.Result<Price, Error>
public protocol CurrentPriceUseCaseType {
    func startObserving()
    func stopObserving()
    var priceResult: ((CurrentPriceResult) -> Void)? { get set }
}


public final class CurrentPriceUseCase: CurrentPriceUseCaseType {
    public var priceResult: ((CurrentPriceResult) -> Void)?
    private let url: URL
    private let client: HTTPClient
    private var timer: Timer?
    
    public init(url: URL, client: HTTPClient, timer: Timer = Timer()) {
        self.url = url
        self.client = client
        self.timer = timer
    }
    
    public func startObserving() {
        guard timer == nil else { return }
        scheduledTimer()
        load()
    }
    
    public func stopObserving() {
        timer?.invalidate()
        timer = nil
    }
    
    
    private func scheduledTimer() {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(load), userInfo: nil, repeats: true)
    }
    
    @objc private func load() {
        let urlRequest = URLRequest(url: url)
        client.get(from: urlRequest) { [self] result in
            switch result {
            case let .success((data, _)):
                do {
                    let d = try JSONDecoder().decode(Bitcon.self, from: data)
                    let price = Price(price: d.bitcoin.current, currency: .EUR)
                    self.priceResult?(.success(price))
                } catch {
                    
                }
            case .failure(let error):
                self.priceResult?(.failure(error))
            }
        }
    }
}
