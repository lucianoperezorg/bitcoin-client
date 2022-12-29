//
//  BitcoinListViewControllerTests.swift
//  iOSTests
//
//  Created by Luciano Perez on 06/12/2022.
//

import XCTest
@testable import iOS
import Domain
import HTTPNetwork

final class BitcoinListViewControllerTests: XCTestCase {
    
    func test_init_willSetTableViewDelegateAndDataSource() {
        let (sut, _, _) = makeSUT()
        
        _ = sut.view
        
        XCTAssertNotNil(sut.historicalPricesTableView.delegate)
        XCTAssertNotNil(sut.historicalPricesTableView.dataSource)
    }
    
    func test_init_activityIndicatorWillRun() {
        let (sut, _, _) = makeSUT()
        
        _ = sut.view
        
        XCTAssertTrue(sut.historicalErrorStackView.alpha == 0)
        XCTAssertTrue(sut.historicalActivityIndicator.isHidden == false)
        XCTAssertTrue(sut.historicalActivityIndicator.isAnimating == true)
    }
    
    func test_init_historicalErrorIsHidden() {
        let (sut, _, _) = makeSUT()
        
        _ = sut.view
        
        XCTAssertTrue(sut.historicalErrorStackView.alpha == 0)
    }
    
    func test_price_loadCurrentPriceWithTheCorrectLabels() {
        let date = Date()
        let (sut, currentPriceUseCase, _) = makeSUT(date: date)
        
        _ = sut.view
        
        let price = Price(value: 234.3, currency: .EUR)
        currentPriceUseCase.priceResultHandler?(.success(price))
        let expectedDateStr = date.toString(dateFormat: "HH:mm:ss")
        XCTAssertEqual(sut.currentPriceLabel.text, "234.3 \(Currency.EUR.rawValue)")
        XCTAssertEqual(sut.currentPriceInfoLabel.text, "\(expectedDateStr) - real-time data")
    }
    
    func test_loadPrice_currentPriceError() {
        let date = Date()
        let (sut, currentPriceUseCase, _) = makeSUT(date: date)
        
        _ = sut.view
        let anyError = NSError(domain: "Any error", code: 0)
        currentPriceUseCase.priceResultHandler?(.failure(anyError))
        
        XCTAssertEqual(sut.currentPriceLabel.text, "00.0000 Euros")
        XCTAssertEqual(sut.currentPriceInfoLabel.text, "An error occurred trying to get the current price.")
    }
    
    func test_load_historicalPricesLoadCorrectly() {
        let date = Date()
        let (sut, _, historial) = makeSUT(date: date)
        let historicalPrice = HistoricalPrice(price: 23.3, currency: .EUR, date: Date())
        historial.stubLoadResult = .success([historicalPrice])
        _ = sut.view
        
        XCTAssertTrue(sut.historicalActivityIndicator.isHidden == true)
        XCTAssertTrue(sut.historicalPricesTableView.alpha == 1)
        XCTAssertTrue(sut.historicalErrorStackView.alpha == 0)
        
        let cell = try? XCTUnwrap(getCellAt(tableView: sut.historicalPricesTableView))
        XCTAssertEqual(cell?.priceLabel.text, "23")
        XCTAssertEqual(cell?.currencyLabel.text, Currency.EUR.rawValue)
        XCTAssertEqual(cell?.dateLabel.text, date.toString(dateFormat: "MMM d, yyyy"))
    }
    
    func test_load_historicalPricesErrorShowsCorrectly() {
        let date = Date()
        let (sut, _, historial) = makeSUT(date: date)
        let anyError = NSError(domain: "Any error", code: 0)
        historial.stubLoadResult = .failure(anyError)
        _ = sut.view
        
        XCTAssertTrue(sut.historicalPricesTableView.numberOfRows(inSection: 0) == 0)
        XCTAssertTrue(sut.historicalActivityIndicator.isHidden == true)
        XCTAssertTrue(sut.historicalPricesTableView.alpha == 0)
        XCTAssertTrue(sut.historicalErrorStackView.alpha == 1)
    }
    
    func test_background_willStopObserving() {
        let date = Date()
        let (sut, currentPriceUseCase, _ ) = makeSUT(date: date)
        _ = sut.view
        sut.appMovedToBackground()
        
        XCTAssertEqual(currentPriceUseCase.stopObservingCalled, 1)
        
        sut.appBecameActive()
        XCTAssertEqual(currentPriceUseCase.startObservingCalled, 1)
    }
    
    func test_viewWillDisappearr_willStopObserving() {
        let date = Date()
        let (sut, currentPriceUseCase, _ ) = makeSUT(date: date)
        _ = sut.view
        sut.viewWillDisappear(true)
        
        XCTAssertEqual(currentPriceUseCase.stopObservingCalled, 1)
        XCTAssertEqual(currentPriceUseCase.startObservingCalled, 0)
    }
    
    func test_viewAppear_willStartObserving_viewDisappear_willStopObserving() {
        let date = Date()
        let (sut, currentPriceUseCase, _ ) = makeSUT(date: date)
        _ = sut.view
        sut.viewWillAppear(true)
        
        XCTAssertEqual(currentPriceUseCase.startObservingCalled, 1)
        
        sut.viewWillDisappear(true)
        XCTAssertEqual(currentPriceUseCase.stopObservingCalled, 1)
    }
    
    func test_load_historicalPricesLoadSortedByDate() {
        let yesterday = Date().dayBefore
        let dayBeforeYesterday = Date().dayBeforeYesterday

        let (sut, _, historial) = makeSUT()
        let price = 23.3
        let historicalPrice1 = HistoricalPrice(price: price, currency: .EUR, date: dayBeforeYesterday)
        let historicalPrice2 = HistoricalPrice(price: price, currency: .EUR, date: yesterday)
        historial.stubLoadResult = .success([historicalPrice1, historicalPrice2])
        _ = sut.view
        
        let cell0 = try? XCTUnwrap(getCellAt(tableView: sut.historicalPricesTableView,index: 0))
        let cell1 = try? XCTUnwrap(getCellAt(tableView: sut.historicalPricesTableView,index: 1))
        XCTAssertEqual(cell0?.dateLabel?.text, yesterday.toString(dateFormat: "MMM d, yyyy"))
        XCTAssertEqual(cell1?.dateLabel?.text, dayBeforeYesterday.toString(dateFormat: "MMM d, yyyy"))
    }
    
    //MARK: - Helpers
    private func getCellAt(tableView: UITableView, index: Int = 0) -> HistoricalPriceTableViewCell? {
        let indexPath =  IndexPath(row: index, section: 0)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath)
        return cell as? HistoricalPriceTableViewCell
    }
    
    private func makeSUT(date: Date = Date()) ->
    (sut: BitcoinListViewController, priceUseCase: CurrentPriceUseCaseMock, historicalPricesUseCase: HistoricalPricesUseCaseMock) {
        let historicalPricesUseCase = HistoricalPricesUseCaseMock()
        let currentPriceUseCase = CurrentPriceUseCaseMock()
        let viewModel = BitcoinListViewModel(historicalPrices: historicalPricesUseCase, currentPrice: currentPriceUseCase, mainDispatchQueue: DispatchQueueMock(), currentDate: { date })
        let sut = BitcoinListViewController(viewModel: viewModel)
        return (sut, currentPriceUseCase, historicalPricesUseCase)
    }
}

private extension Date {
    static var yesterday: Date { return Date().dayBefore }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayBeforeYesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: noon)!
    }
    private var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
}
