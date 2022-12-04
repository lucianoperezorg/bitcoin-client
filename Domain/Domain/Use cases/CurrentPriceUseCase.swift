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
    private let url: URL
    private let client: HTTPClient
    private var timer: Timer?

    public var priceResultHandler: ((CurrentPriceResult) -> Void)?

    public init(url: URL, client: HTTPClient, timer: Timer = Timer()) {
        self.url = url
        self.client = client
        self.timer = timer
    }
    
    public func startObserving() {
        guard timer == nil else { return }
        scheduledTimer()
        loadCurrentPrice()
    }
    
    public func stopObserving() {
        timer?.invalidate()
        timer = nil
    }
    
    private var FREQUENCY: TimeInterval { return 60 }
    private func scheduledTimer() {
        timer = Timer.scheduledTimer(timeInterval: FREQUENCY, target: self, selector: #selector(loadCurrentPrice), userInfo: nil, repeats: true)
    }
    
    @objc private func loadCurrentPrice() {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                self.priceResultHandler?(CurrentPriceUseCase.map(data, response: response))
            case .failure(let error):
                self.priceResultHandler?(.failure(error))
            }
        }
    }
}

private extension CurrentPriceUseCase {
    static func map(_ data: Data, response: URLResponse) -> CurrentPriceResult {
        do {
            let rootPrice = try JSONDecoder().decode(RemoteCurrentPrice.self, from: data)
            let price = Price(price: rootPrice.price.current, currency: .EUR)
            return .success(price)
        } catch {
            return .failure(error)
        }
    }
}

