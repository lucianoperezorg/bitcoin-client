//
//  BitcoinDetailViewControllerTests.swift
//  iOSTests
//
//  Created by Luciano Perez on 06/12/2022.
//

import XCTest
@testable import iOS
import Domain
import HTTPNetwork

final class BitcoinDetailViewControllerTests: XCTestCase {
    
    func test_init_willSetTableViewDelegateAndDataSource() {
        let (sut, _) = makeSUT()
        
        _ = sut.view
        
        XCTAssertNotNil(sut.tableView.delegate)
        XCTAssertNotNil(sut.tableView.dataSource)
    }
    
    func test_loadView_currencyListRenderOnScreen() {
        let date = Date()
        let (sut, detailUseCase) = makeSUT(date: date)
        let prices = [
            Price(value: 1.3, currency: .EUR),
            Price(value: 2.2, currency: .USD)
        ]
        detailUseCase.currencyDetailResultStub = .success(prices)
        _ = sut.view

        let cellAtIndex0 = try? XCTUnwrap(getCellAt(tableView: sut.tableView))
        let cellAtIndex1 = try? XCTUnwrap(getCellAt(tableView: sut.tableView, index: 1))
        XCTAssertEqual(cellAtIndex0?.textLabel?.text, "\(Currency.EUR.icon) 1 \(Currency.EUR.description)")
        XCTAssertEqual(cellAtIndex1?.textLabel?.text, "\(Currency.USD.icon) 2 \(Currency.USD.description)")
        XCTAssertEqual(sut.errorLabel.alpha, 0)
    }
    
    func test_loadView_errorRenderOnScreenOnApiFails() {
        let date = Date()
        let (sut, detailUseCase) = makeSUT(date: date)
       
        let anyError = NSError(domain: "Any error", code: 0)
        detailUseCase.currencyDetailResultStub = .failure(anyError)
        _ = sut.view
        
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(sut.errorLabel.alpha, 1)
    }
    
    //MARK: - helpers
    private func getCellAt(tableView: UITableView, index: Int = 0) -> UITableViewCell? {
        let indexPath =  IndexPath(row: index, section: 0)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath)
        return cell
    }
    
    private func makeSUT(date: Date = Date()) ->
    (sut: BitcoinDetailViewController, currencyDetailUseCase: CurrencyDetailUseCaseMock) {
        
        let currencyDetailUseCase = CurrencyDetailUseCaseMock()
        let viewModel = BitcoinDetailViewModel(currencyDetailUseCase: currencyDetailUseCase, selectedDate: date, mainDispatchQueue: DispatchQueueMock())
        let sut = BitcoinDetailViewController(viewModel: viewModel)

        return (sut, currencyDetailUseCase)
    }
}
