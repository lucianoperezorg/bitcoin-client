//
//  BitcoinListViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit


class BitcoinListViewController: UIViewController {
    @IBOutlet weak var historicalPricesTableView: UITableView!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var historicalActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryHistoricalButton: UIButton!
    @IBOutlet weak var currentPriceInfoLabel: UILabel!
    @IBOutlet weak var historicalErrorStackView: UIStackView!

    private let viewModel: BitcoinListViewModel
    
    init(viewModel: BitcoinListViewModel) {
        self.viewModel = viewModel
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
        self.bind()
        self.viewModel.viewDidLoad()
        self.configureTableView()
       
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func bind() {
        self.viewModel.onCurrectLoaded = { message in
            self.currentPriceLabel.text = message.currentPrice
            self.currentPriceInfoLabel.text = message.updateMessage
        }
        
        self.viewModel.onHistoricalPriceLoadedSucess = {
            self.historicalPricesTableView.reloadData()
            self.manageHistoricalSuccessResult()
            
        }
        self.viewModel.onHistoricalPriceLoadedFail = {
            self.manageHistoricalErrorResult()
        }
    }
    
    @objc func appMovedToBackground() {
        viewModel.appBecameInactive()
    }
    
    @objc func appBecameActive() {
        viewModel.appBecameActive()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.appBecameActive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.appBecameInactive()
    }
    
    @IBAction func realoadHistoricalTouch(_ sender: Any) {
        viewModel.loadHistoricalPrice()
    }
    
    private func manageHistoricalErrorResult() {
        historicalActivityIndicator.stopAnimating()
        historicalPricesTableView.alpha = 0
        historicalErrorStackView.alpha = 1
    }
    
    private func manageHistoricalSuccessResult() {
        historicalPricesTableView.reloadData()
        historicalActivityIndicator.stopAnimating()
        historicalErrorStackView.alpha = 0
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension BitcoinListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.historicalPrices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let price = viewModel.historicalPrices[indexPath.row]
        
        cell.textLabel?.text = "\(Int(price.price)) \(price.currency.description) - \(price.date.toString())"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let price = viewModel.historicalPrices[indexPath.row]
        navigateTo(date: price.date)
    }
    
    private func navigateTo(date: Date) {
        guard let currencyDetail = viewModel.getCurrencyDetailUseCase(for: date) else { return }
        let vc = BitcoinDetailViewController(currencyDetailUseCase: currencyDetail, selectedDate: date)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureTableView() {
        historicalPricesTableView.delegate = self
        historicalPricesTableView.dataSource = self
        historicalPricesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
}