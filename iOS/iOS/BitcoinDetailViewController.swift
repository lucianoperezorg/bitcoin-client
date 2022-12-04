//
//  BitcoinDetailViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit
import Domain

class BitcoinDetailViewController: UIViewController {
    
    @IBOutlet weak var poundLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var euroLabel: UILabel!
    
    private let currencyDetailUseCase: CurrencyDetailUseCaseType
    
    init(currencyDetailUseCase: CurrencyDetailUseCaseType) {
        self.currencyDetailUseCase = currencyDetailUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currencyDetailUseCase.currencyDetail { result in
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
