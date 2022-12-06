//
//  BitcoinListViewModel.swift
//  iOS
//
//  Created by Luciano Perez on 06/12/2022.
//

import Foundation
import Domain
import HTTPNetwork

final class BitcoinListViewModel {
    private var historicalPrices = [HistoricalPrice]()
    private let historicalPricesUseCase: HistoricalPricesUseCaseType
    private var currentPrice: CurrentPriceUseCaseType
    private let mainDispatchQueue: DispatchQueueType
    private let currentDate: (() -> Date)
    
    init(historicalPrices: HistoricalPricesUseCaseType, currentPrice: CurrentPriceUseCaseType, mainDispatchQueue: DispatchQueueType = DispatchQueue.main, currentDate: @escaping (() -> Date) = { Date() } ) {
        self.currentPrice = currentPrice
        self.historicalPricesUseCase = historicalPrices
        self.mainDispatchQueue = mainDispatchQueue
        self.currentDate = currentDate
    }
    
    public func appBecameActive() {
        self.currentPrice.startObserving()
    }
    
    public func appBecameInactive() {
        self.currentPrice.stopObserving()
    }
    
    public func viewLoaded() {
        loadHistoricalPrice()
        loadCurrentPrice()
    }
    
    private func loadCurrentPrice() {
        currentPrice.priceResultHandler = { result in
            self.mainDispatchQueue.async {
                self.handledCurrentUpdated(with: result)
            }
        }
    }
    
    struct CurrectPriceBinder {
        let currentPrice: String
        let updateMessage: String
    }
    
    var onCurrectLoaded: ((CurrectPriceBinder) -> Void)?
    private func handledCurrentUpdated(with result: CurrentPriceResult) {
        switch result {
        case .success(let price):
            mainDispatchQueue.async {
                self.onCurrectLoaded?(self.currentPriceSuccessMessage(price: price))
            }
        case .failure:
            mainDispatchQueue.async {
                self.onCurrectLoaded?(self.currentPriceErrorMessage)
            }
        }
    }
    
    private var currentPriceErrorMessage: CurrectPriceBinder {
        let updateMessage  = "00.0000 Euros"
        let currenctPriceMessage  = "An error occurred trying to get the current price."
        let currectPrice = CurrectPriceBinder(currentPrice: updateMessage, updateMessage: currenctPriceMessage)
        return currectPrice
    }
    
    private func currentPriceSuccessMessage(price: Price) -> CurrectPriceBinder {
        let upDateMessage = "\(self.currentDate().toString(dateFormat: "HH:mm:ss")) - real-time data"
        let currenctPriceMessage = "\(price.value) \(price.currency.description)"
        let currectPrice = CurrectPriceBinder(currentPrice: currenctPriceMessage, updateMessage: upDateMessage)
        return currectPrice
    }
    
    var onHistoricalPriceLoadedSucess: (() -> Void)?
    var onHistoricalPriceLoadedFail: (() -> Void)?
    func loadHistoricalPrice() {
        historicalPricesUseCase.load { [weak self] result in
            guard let self = self else { return }
            self.mainDispatchQueue.async {
                self.handleLoadHistoricalResult(result)
            }
        }
    }
    var pricesCount: Int { historicalPrices.count }
    
    func priceAt(index: Int) -> HistoricalPrice {
        return historicalPrices[index]
    }

    func getTitleFor(index: Int) -> String {
        let price = priceAt(index: index)
        return "\(Int(price.price)) \(price.currency.description) - \(price.date.toString())"
    }
    
    func handleLoadHistoricalResult(_ result: HistoricalPricesResult) {
        switch result {
        case .success(let prices):
            historicalPrices = prices.sorted(by: { $0.date > $1.date })
            onHistoricalPriceLoadedSucess?()
        case .failure:
            onHistoricalPriceLoadedFail?()
        }
    }
    
    func getDetailViewModel(for date: Date) -> BitcoinDetailViewModel? {
        guard let url = Resource.PricesDetail(dateString: date.toString()).resolveUrl else { return nil }
        let currencyDetail = CurrencyDetailUseCase(url: url, client: URLSessionHTTPClient())
        let viewModel = BitcoinDetailViewModel(currencyDetailUseCase: currencyDetail, selectedDate: date)
        return viewModel
    }
}


