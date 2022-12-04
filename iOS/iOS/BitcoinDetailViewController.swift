//
//  BitcoinDetailViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit

class BitcoinDetailViewController: UIViewController {
    
    @IBOutlet weak var poundLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var euroLabel: UILabel!
    
    private let date: Date
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let stringDate = dateFormatter.string(from: self.date)
        let stringURL = "https://api.coingecko.com/api/v3/coins/bitcoin/history?date=\(stringDate)&localization=false"
        var dddd = 3

        let url = URL(string: stringURL)!
        URLSession.shared.dataTask(with: url) { data, res, err in
            if let error = err {
            } else if let data = data {
                do {
                    let d = try? JSONDecoder().decode(marketData.self, from: data)
                    var ddd = 3
                    DispatchQueue.main.async {
                        self.usdLabel.text = "USD: \(Int(d!.market_data.current_price.usd))"
                        self.euroLabel.text = "EUR: \(Int(d!.market_data.current_price.eur))"
                        self.poundLabel.text = "POUND: \(Int(d!.market_data.current_price.gbp))"
                    }
                } catch {}
            }
        }.resume()
    }
    
    struct  marketData : Decodable {
        let market_data: CurrentPrice
    }
    
    struct CurrentPrice : Decodable {
        let current_price: Prices
    }
    
    struct Prices: Decodable {
        let usd: Double
        let eur: Double
        let gbp: Double
    }
    
    init(date: Date) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
