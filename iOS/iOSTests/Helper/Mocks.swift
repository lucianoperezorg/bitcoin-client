//
//  Mocks.swift
//  iOSTests
//
//  Created by Luciano Perez on 06/12/2022.
//

import Foundation
@testable import iOS
import Domain
import HTTPNetwork

class HistoricalPricesUseCaseMock: HistoricalPricesUseCaseType {
    var stubLoadResult: HistoricalPricesResult? = nil
    func load(completion: @escaping (Domain.HistoricalPricesResult) -> Void) {
        if let stubLoadResult = stubLoadResult {
            completion(stubLoadResult)
        }
    }
}

class CurrentPriceUseCaseMock: CurrentPriceUseCaseType {
    var startObservingCalled = 0
    func startObserving() {
        startObservingCalled += 1
    }
    
    var stopObservingCalled = 0
    func stopObserving() {
        stopObservingCalled += 1
    }
    
    var priceResultHandler: ((Domain.CurrentPriceResult) -> Void)?
}

class CurrencyDetailUseCaseMock: CurrencyDetailUseCaseType {
    var currencyDetailResultStub: CurrencyDetailResult?
    func currencyDetail(completion: @escaping (Domain.CurrencyDetailResult) -> Void) {
        if let currencyDetailResultStub = currencyDetailResultStub {
            completion(currencyDetailResultStub)
        }
    }
}
