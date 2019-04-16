//
//  AppDelegate.swift
//  haiku
//
//  Created by Mitchell Gerber on 8/6/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var backgroundTimestamp = Date()
    /// time interval to refresh the app views - 15 minutes
    private let refreshTime = Double(15 * 60)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)

        // https://realm.io/docs/swift/latest/#migrations
        StorageService.shared.realmMigrations()
        
        self.setupTabBarController()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        GlobalPlayer.shared.pause()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.backgroundTimestamp = Date()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        // reload the tab view controller if in background for certain period of time
        let time = Date().timeIntervalSince(self.backgroundTimestamp)
        if time > self.refreshTime {
            self.setupTabBarController()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupTabBarController() {
        let tc = MyTabBarController()
        tc.title = "Live Stream Fails"
        tc.tabBar.isTranslucent = false
        tc.tabBar.tintColor = Config.colors.primaryFont
        
        let navigationController = UINavigationController(rootViewController: tc)
        navigationController.navigationBar.isTranslucent = false

        let mainCollectionViewController = MainCollectionViewController()
        mainCollectionViewController.tabBarItem = Icons.getTabBarItem(icon: .tv, selectedIcon: .tvFill, tag: 0)

        let favoritesCollectionViewController = FavoritesCollectionViewController()
        favoritesCollectionViewController.tabBarItem = Icons.getTabBarItem(icon: .heart, selectedIcon: .heartFill, tag: 1)

        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = Icons.getTabBarItem(icon: .settings, selectedIcon: .settingsFill, tag: 2)

        tc.viewControllers = [mainCollectionViewController, favoritesCollectionViewController, settingsViewController]
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return .portrait
    }
}
