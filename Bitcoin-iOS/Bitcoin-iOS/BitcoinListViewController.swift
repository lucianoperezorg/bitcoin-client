//
//  BitcoinListViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit
import Domain

class BitcoinListViewController: UIViewController {
    
    @IBOutlet weak var historicalPricesTableView: UITableView!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    private var historiaclaPrice = [BitcoinPricesModel]()
    
    private let historicalPricesUseCase: HistoricalPricesUseCaseType
    private let currentPrice: CurrentPriceUseCaseType
    
    init(historicalPrices: HistoricalPricesUseCaseType, currentPrice: CurrentPriceUseCaseType) {
        self.currentPrice = currentPrice
        self.historicalPricesUseCase = historicalPrices
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historicalPricesTableView.delegate = self
        historicalPricesTableView.dataSource = self
        historicalPricesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        currentPrice.load { result in
            switch result {
            case .success(let price):
                DispatchQueue.main.async {
                    self.currentPriceLabel.text = "\(price.price) \(price.currency.description)"
                }
            case .failure:
                break
            }
        }
        
        historicalPricesUseCase.load { result in
            switch result {
            case .success(let prices):
                DispatchQueue.main.async {
                    self.historiaclaPrice = prices
                    self.historicalPricesTableView.reloadData()
                }
            case .failure:
                break
            }
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension BitcoinListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historiaclaPrice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let price = historiaclaPrice[indexPath.row]
        
        cell.textLabel?.text = "Eur \(Int(price.price)) - on:  \(price.date.toString())"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let price = historiaclaPrice[indexPath.row]
        let vc = BitcoinDetailViewController(date: price.date)
        navigationController?.pushViewController(vc, animated: true)
    }
}


//TODO: move this from here
extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        return dateFormatter.string(from: self)
    }
}
