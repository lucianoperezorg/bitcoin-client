//
//  CurrentPriceUseCase.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation
import HTTPNetwork

public typealias CurrentPriceResult = Swift.Result<Price, Error>
public protocol CurrentPriceUseCaseType {
    func startObserving()
    func stopObserving()
    var priceResultHandler: ((CurrentPriceResult) -> Void)? { get set }
}


public final class CurrentPriceUseCase: CurrentPriceUseCaseType {
    public var priceResultHandler: ((CurrentPriceResult) -> Void)?
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
        client.get(from: url) { [self] result in
            switch result {
            case let .success((data, _)):
                do {
                    let rootPrice = try JSONDecoder().decode(RemoteCurrentPrice.self, from: data)
                    let price = Price(price: rootPrice.price.current, currency: .EUR)
                    self.priceResultHandler?(.success(price))
                } catch {
                    
                }
            case .failure(let error):
                self.priceResultHandler?(.failure(error))
            }
        }
    }
}




//TODO: move this from here
private struct RemoteCurrentPrice: Decodable {
    let price: RemotePrice
    
    enum CodingKeys: String, CodingKey {
        case price = "bitcoin"
    }
}

public struct RemotePrice: Decodable {
    public let current: Double
    
    enum CodingKeys: String, CodingKey {
        case current = "eur"
    }
}
