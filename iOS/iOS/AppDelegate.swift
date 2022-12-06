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
        
        let historicalPricesUseCase = HistoricalPricesUseCase(url: Resource.historicalPrices.resolveUrl!, client: URLSessionHTTPClient())
        let currentPriceUseCase = CurrentPriceUseCase(url: Resource.currentPrice.resolveUrl!, client: URLSessionHTTPClient(), schedulerTimer: SchedulerTimer(frecuency: 60, repeats: true))
        
        let navigator = UINavigationController(rootViewController: BitcoinListViewController(historicalPrices: historicalPricesUseCase, currentPrice: currentPriceUseCase))
        
        window.rootViewController = navigator
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
    
}

