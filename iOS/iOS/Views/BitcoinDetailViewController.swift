//
//  BitcoinDetailViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit
import Domain

class BitcoinDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorLabel: UILabel!
    private let currencyDetailUseCase: CurrencyDetailUseCaseType
    private var prices = [Price]()
    private let selectedDate: Date
    private let mainDispatchQueue: DispatchQueueType
    
    init(currencyDetailUseCase: CurrencyDetailUseCaseType, selectedDate: Date,
         mainDispatchQueue: DispatchQueueType = DispatchQueue.main) {
        self.currencyDetailUseCase = currencyDetailUseCase
        self.selectedDate = selectedDate
        self.mainDispatchQueue = mainDispatchQueue
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.titleLabel.text = "Bitcon price on \(selectedDate.toString())"
        self.loadingActivityIndicator.startAnimating()
        self.loadingActivityIndicator.alpha = 1
        self.titleLabel.alpha = 0
        
        self.configureTableView()
        self.startLoadingCurrencyDetail()
    }
    
    private func startLoadingCurrencyDetail() {
        currencyDetailUseCase.currencyDetail { result in
            switch result {
            case .success(let prices):
                self.prices = prices
                self.loadedPricesSuccessfully()
            case .failure:
                self.presentErrorAlert()
            }
        }
    }
    
    private func loadedPricesSuccessfully() {
        mainDispatchQueue.async {
            self.loadingActivityIndicator.stopAnimating()
            self.loadingActivityIndicator.alpha = 0.0
            self.titleLabel.alpha = 1
            self.errorLabel.alpha = 0
            self.tableView.reloadData()
        }
    }
    
    private func presentErrorAlert() {
        mainDispatchQueue.async {
            self.errorLabel.alpha = 1
            self.errorLabel.text = "An error occured, please go back and try it again."
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK:  UITableViewDataSource, UITableViewDelegate
extension BitcoinDetailViewController: UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let price = prices[indexPath.row]
        cell.textLabel?.text = "\(price.currency.description) : \(Int(price.value))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        prices.count
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
}
