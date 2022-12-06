//
//  HistoricalPriceTableViewCell.swift
//  iOS
//
//  Created by Luciano Perez on 06/12/2022.
//

import UIKit

class HistoricalPriceTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellFor(_ historicalPrice: HistoricalPriceBinder) {
        dateLabel.text = historicalPrice.date
        currencyLabel.text = historicalPrice.currency
        priceLabel.text = historicalPrice.price
    }
    
}
