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
    
    private let currencyDetailUseCase: CurrencyDetailUseCaseType
    private var prices = [Price]()
    private let selectedDate: Date
    
    init(currencyDetailUseCase: CurrencyDetailUseCaseType, selectedDate: Date) {
        self.currencyDetailUseCase = currencyDetailUseCase
        self.selectedDate = selectedDate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        titleLabel.text = "Bitcon price on \(selectedDate.toString())"
        
        loadingActivityIndicator.startAnimating()
        loadingActivityIndicator.alpha = 1
        titleLabel.alpha = 0

        currencyDetailUseCase.currencyDetail { result in
            
            switch result {
            case .success(let prices):
                DispatchQueue.main.async {
                    self.prices = prices
                    self.loadingActivityIndicator.stopAnimating()
                    self.loadingActivityIndicator.alpha = 0.0
                    self.titleLabel.alpha = 1
                    self.tableView.reloadData()
                }
            case .failure:
                self.presentAlert()
            }
        }
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "Internal Error", message: "An error occurred, please go back and try again.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
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
}
