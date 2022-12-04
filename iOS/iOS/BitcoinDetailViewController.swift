//
//  BitcoinDetailViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit
import Domain

class BitcoinDetailViewController: UIViewController {
    @IBOutlet weak var containerPricesView: UIStackView!
    
    @IBOutlet weak var poundLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var euroLabel: UILabel!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    private let currencyDetailUseCase: CurrencyDetailUseCaseType
    
    init(currencyDetailUseCase: CurrencyDetailUseCaseType) {
        self.currencyDetailUseCase = currencyDetailUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingActivityIndicator.startAnimating()
        loadingActivityIndicator.alpha = 1
        containerPricesView.alpha = 0.0
        currencyDetailUseCase.currencyDetail { result in
            DispatchQueue.main.async {
                self.loadingActivityIndicator.stopAnimating()
                self.loadingActivityIndicator.alpha = 0.0
                self.containerPricesView.alpha = 1.0
            }
            switch result {
            case .success(let price):
                DispatchQueue.main.async {
                    self.usdLabel.text = "\(price[0].currency.description) : \(Int(price[0].price))"
                    self.euroLabel.text = "\(price[1].currency.description) : \(Int(price[1].price))"
                    self.poundLabel.text = "\(price[0].currency.description) : \(Int(price[2].price))"
                }
            case .failure:
                break
            }
        }
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
