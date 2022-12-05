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
    func getCalled()
}

public protocol SchedulerTimerType: AnyObject {
    func startObserving(observed: SchedulerTimerDelegate)
    func stopObserving()
    var schedulerTimerDelegate: SchedulerTimerDelegate? { get set }
}

public class SchedulerTimer: SchedulerTimerType {
    private let frecuency: TimeInterval
    private var timer: Timer?
    private let repeats: Bool
    
    weak public var schedulerTimerDelegate: SchedulerTimerDelegate?
    
    public init(frecuency: TimeInterval = 10, repeats: Bool = true) {
        self.frecuency = frecuency
        self.repeats = repeats
    }
    
    private func scheduledTimer() {
        timer = Timer.scheduledTimer(timeInterval: frecuency, target: self, selector: #selector(handlerCalled), userInfo: nil, repeats: repeats)
    }
    
    public func startObserving(observed: SchedulerTimerDelegate) {
        schedulerTimerDelegate = observed
        scheduledTimer()
        handlerCalled()
    }
    
    public func stopObserving() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func handlerCalled() {
        schedulerTimerDelegate?.getCalled()
    }
}

public final class CurrentPriceUseCase: CurrentPriceUseCaseType {
    private let url: URL
    private let client: HTTPClient
    private let timer: SchedulerTimerType
    
    public var priceResultHandler: ((CurrentPriceResult) -> Void)?

    public init(url: URL, client: HTTPClient, timer: SchedulerTimerType = SchedulerTimer()) {
        self.url = url
        self.client = client
        self.timer = timer
    }
    
    public func startObserving() {
        timer.startObserving(observed: self)
    }
    
    public func stopObserving() {
        timer.stopObserving()
    }
    private  var OK_200: Int { return 200 }
    
    private func loadCurrentPrice() {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                if response.statusCode != self.OK_200 {
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
            let price = Price(value: rootPrice.price.current, currency: .EUR)
            return .success(price)
        } catch {
            return  .failure(PriceError.dataCorrupted)
        }
    }
}

extension CurrentPriceUseCase: SchedulerTimerDelegate {
    public func getCalled() {
        loadCurrentPrice()
    }
}
