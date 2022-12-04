//
//  AppDelegate.swift
//  iOS
//
//  Created by Luciano Perez on 04/12/2022.
//

import UIKit
import HTTPNetwork
import Domain

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
           let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=eur&days=20&interval=daily")!
           let d = HistoricalPricesUseCase(url: url, client: URLSessionHTTPClient())
           
           let ur3l = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=eur")!

           let ddd = CurrentPriceUseCase(url: ur3l, client: URLSessionHTTPClient())
           let navigator = UINavigationController(rootViewController: BitcoinListViewController(historicalPrices: d, currentPrice: ddd))
           window.rootViewController = navigator
           self.window = window
           window.makeKeyAndVisible()
        return true
    }

}

