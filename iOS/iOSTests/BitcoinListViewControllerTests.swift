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
    
    func test_price_loadCurrentPriceWithTheCorrectLabels() {
        let date = Date()
        let (sut, currentPriceUseCase, _) = makeSUT(date: date)
        
        _ = sut.view
        
        let price = Price(value: 234.3, currency: .EUR)
        currentPriceUseCase.priceResultHandler?(.success(price))
        
        let expectedDateStr = date.toString(dateFormat: "HH:mm:ss")
        XCTAssertEqual(sut.currentPriceLabel.text, "234.3 EUR")
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
        
        XCTAssertTrue(sut.historicalPricesTableView.numberOfRows(inSection: 0) == 1)
        XCTAssertTrue(sut.historicalActivityIndicator.isHidden == true)
        XCTAssertTrue(sut.historicalPricesTableView.alpha == 1)
        XCTAssertTrue(sut.historicalErrorStackView.alpha == 0)
        
        let cell = try? XCTUnwrap(getCellAt(tableView: sut.historicalPricesTableView))
        XCTAssertEqual(cell?.textLabel?.text, "23 EUR - 06-12-2022")
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
    
    //MARK: - Helpers
    private func getCellAt(tableView: UITableView, index: Int = 0) -> UITableViewCell? {
        let indexPath =  IndexPath(row: index, section: 0)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath)
        return cell
    }
    
    private func makeSUT(date: Date = Date()) ->
    (sut: BitcoinListViewController, priceUseCase: CurrentPriceUseCaseMock, historicalPricesUseCase: HistoricalPricesUseCaseMock) {
        let historicalPricesUseCase = HistoricalPricesUseCaseMock()
        let currentPriceUseCase = CurrentPriceUseCaseMock()
        let sut = BitcoinListViewController(historicalPrices: historicalPricesUseCase, currentPrice: currentPriceUseCase, mainDispatchQueue: DispatchQueueMock(), date: { date })
        return (sut, currentPriceUseCase, historicalPricesUseCase)
    }
}
