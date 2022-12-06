//
//  BitcoinDetailViewModel.swift
//  iOS
//
//  Created by Luciano Perez on 06/12/2022.
//

import Foundation
import Domain

final class BitcoinDetailViewModel {
    private let currencyDetailUseCase: CurrencyDetailUseCaseType
    private var prices = [Price]()
    private let selectedDate: Date
    private let mainDispatchQueue: DispatchQueueType
    
    var historicalPricesCount: Int { prices.count }
    var title: String { "Bitcon price on \(selectedDate.toString())" }
    
    init(currencyDetailUseCase: CurrencyDetailUseCaseType, selectedDate: Date,
         mainDispatchQueue: DispatchQueueType = DispatchQueue.main) {
        self.currencyDetailUseCase = currencyDetailUseCase
        self.selectedDate = selectedDate
        self.mainDispatchQueue = mainDispatchQueue
    }
    
    var onLoading: (() -> Void)?
    func viewLoaded() {
        mainDispatchQueue.async {
            self.onLoading?()
        }
        loadingCurrencyDetail()
    }
    
    private func priceAt(index: Int) -> Price {
        return prices[index]
    }

    func getTitleFor(index: Int) -> String {
        let price = priceAt(index: index)
        return "\(price.currency.description) : \(Int(price.value))"
    }
    
    private func loadingCurrencyDetail() {
        currencyDetailUseCase.currencyDetail { result in
            self.mainDispatchQueue.async {
                self.handleLoadingCurrenciesResult(result: result)
            }
        }
    }
    
    var onSuccessLoadCurrenciesDetail: (() -> Void)?
    var onFailLoadCurrenciesDetail: ((String) -> Void)?
    private func handleLoadingCurrenciesResult(result: CurrencyDetailResult) {
        switch result {
        case .success(let prices):
            self.prices = prices
            self.onSuccessLoadCurrenciesDetail?()
        case .failure:
            self.onFailLoadCurrenciesDetail?("An error occured, please go back and try it again.")
        }
    }
}
