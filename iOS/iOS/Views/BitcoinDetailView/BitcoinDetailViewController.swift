//
//  BitcoinDetailViewController.swift
//  Bitcoin-iOS
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit

class BitcoinDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    private let viewModel: BitcoinDetailViewModel
    
    init(viewModel: BitcoinDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bind()
        self.viewModel.viewLoaded()
        self.title = viewModel.title
        self.configureTableView()
    }
    
    private func bind() {
        viewModel.onSuccessLoadCurrenciesDetail = {
            self.loadedPricesSuccessfully()
        }
        
        viewModel.onFailLoadCurrenciesDetail = { message in
            self.presentErrorAlert(message)
        }
        
        viewModel.onLoading = {
            self.configureViewAsLoading()
        }
    }
    
    private func configureViewAsLoading() {
        self.loadingActivityIndicator.startAnimating()
        self.loadingActivityIndicator.alpha = 1
    }
    
    private func loadedPricesSuccessfully() {
        self.loadingActivityIndicator.stopAnimating()
        self.loadingActivityIndicator.alpha = 0.0
        self.errorLabel.alpha = 0
        self.tableView.reloadData()
    }
    
    private func presentErrorAlert(_ message: String) {
        errorLabel.alpha = 1
        errorLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:  UITableViewDataSource, UITableViewDelegate
extension BitcoinDetailViewController: UITableViewDataSource, UITableViewDelegate  {
    private var cellId: String { return "cellId" }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = viewModel.getTitleFor(index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.historicalPricesCount
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
}
