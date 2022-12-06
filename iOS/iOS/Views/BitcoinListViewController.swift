//
//  BitcoinListViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit
import Domain
import HTTPNetwork

class BitcoinListViewController: UIViewController {
    @IBOutlet weak var historicalPricesTableView: UITableView!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var historicalActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryHistoricalButton: UIButton!
    @IBOutlet weak var currentPriceInfoLabel: UILabel!
    @IBOutlet weak var historicalErrorStackView: UIStackView!
    
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
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func currentPriceTouch(_ sender: Any) {
        navigateTo(date: Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        self.loadCurrentPrice()
        self.loadHistoricalPrice()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        currentPrice.stopObserving()
    }
    
    @objc func appBecameActive() {
        currentPrice.startObserving()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentPrice.startObserving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentPrice.stopObserving()
    }
    
    @objc private func loadCurrentPrice() {
        currentPrice.priceResultHandler = { result in
            self.mainDispatchQueue.async {
                self.handledCurrentUpdated(with: result)
            }
        }
    }
    
    private func handledCurrentUpdated(with result: CurrentPriceResult) {
        switch result {
        case .success(let price):
            self.currentPriceInfoLabel.text = "\(self.currentDate().toString(dateFormat: "HH:mm:ss")) - real-time data"
            self.currentPriceLabel.text = "\(price.value) \(price.currency.description)"
        case .failure:
            self.currentPriceLabel.text = "00.0000 Euros"
            self.currentPriceInfoLabel.text = "An error occurred trying to get the current price."
        }
    }
    
    @IBAction func realoadHistoricalTouch(_ sender: Any) {
        loadHistoricalPrice()
    }
    
    private func loadHistoricalPrice() {
        historicalActivityIndicator.startAnimating()
        presentHistoricalError(enabled: false)
        
        historicalPricesUseCase.load { result in
            switch result {
            case .success(let prices):
                self.historicalPrices = prices
                self.manageHistoricalSuccessResult()
            case .failure:
                self.manageHistoricalErrorResult()
            }
        }
    }
    
    private func manageHistoricalErrorResult() {
        mainDispatchQueue.async {
            self.historicalActivityIndicator.stopAnimating()
            self.historicalPricesTableView.alpha = 0
            self.presentHistoricalError()
        }
    }
    
    private func manageHistoricalSuccessResult() {
        mainDispatchQueue.async {
            self.historicalPricesTableView.reloadData()
            self.historicalActivityIndicator.stopAnimating()
            self.historicalPricesTableView.alpha = 1
            self.presentHistoricalError(enabled: false)
        }
    }
    
    private func presentHistoricalError(enabled: Bool = true) {
        historicalErrorStackView.alpha = enabled.floatValue
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension BitcoinListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historicalPrices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let price = historicalPrices[indexPath.row]
        
        cell.textLabel?.text = "\(Int(price.price)) \(price.currency.description) - \(price.date.toString())"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let price = historicalPrices[indexPath.row]
        navigateTo(date: price.date)
    }
    
    private func navigateTo(date: Date) {
        guard let url = Resource.PricesDetail(dateString: date.toString()).resolveUrl else { return }
        
        let currencyDetail = CurrencyDetailUseCase(url: url, client: URLSessionHTTPClient())
        
        let vc = BitcoinDetailViewController(currencyDetailUseCase: currencyDetail, selectedDate: date)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureTableView() {
        historicalPricesTableView.delegate = self
        historicalPricesTableView.dataSource = self
        historicalPricesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
}
