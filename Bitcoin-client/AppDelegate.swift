//
//  AppDelegate.swift
//  Bitcoin-client
//
//  Created by Luciano Perez on 03/12/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigator = UINavigationController(rootViewController: BitcoinListViewController())
        window.rootViewController = navigator
        self.window = window
        window.makeKeyAndVisible()
    
        return true
    }

}

