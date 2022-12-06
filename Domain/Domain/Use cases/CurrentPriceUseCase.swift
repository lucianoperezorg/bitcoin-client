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

public protocol SchedulerTimerDelegate: AnyObject {
    func handlerTriggered()
}

public final class CurrentPriceUseCase: CurrentPriceUseCaseType {
    private let url: URL
    private let client: HTTPClient
    private let schedulerTimer: SchedulerTimerType
    
    public var priceResultHandler: ((CurrentPriceResult) -> Void)?
    private var Ok200: Int { return 200 }
    
    public init(url: URL, client: HTTPClient, schedulerTimer: SchedulerTimerType) {
        self.url = url
        self.client = client
        self.schedulerTimer = schedulerTimer
    }
    
    public func startObserving() {
        schedulerTimer.startObserving(observed: self)
    }
    
    public func stopObserving() {
        schedulerTimer.stopObserving()
    }
    
    private func loadCurrentPrice() {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                if response.statusCode != self.Ok200 {
                    self.priceResultHandler?(.failure(PriceError.invalidData))
                    return
                }
                self.priceResultHandler?(CurrentPriceUseCase.map(data, response: response))
            case .failure:
                self.priceResultHandler?(.failure(PriceError.invalidData))
            }
        }
    }
}

private extension CurrentPriceUseCase {
    static func map(_ data: Data, response: URLResponse) -> CurrentPriceResult {
        do {
            let rootPrice = try JSONDecoder().decode(RemoteCurrentPrice.self, from: data)
            let price = Price(value: rootPrice.price.current, currency: Config.DEFAULT_CURRENCY)
            return .success(price)
        } catch {
            return .failure(PriceError.dataCorrupted)
        }
    }
}

extension CurrentPriceUseCase: SchedulerTimerDelegate {
    public func handlerTriggered() {
        loadCurrentPrice()
    }
}
