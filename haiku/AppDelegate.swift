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
    private let myTabBarController = MyTabBarController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)

        // https://realm.io/docs/swift/latest/#migrations
        StorageService.shared.realmMigrations()
        
        self.myTabBarController.tabBar.isTranslucent = false
        self.myTabBarController.tabBar.tintColor = Config.colors.primaryFont
        
        self.myTabBarController.viewControllers = self.getTabBarControllers()
        
        self.window?.rootViewController = self.myTabBarController
        self.window?.makeKeyAndVisible()

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
        // reset tabs on tab bar controller - this reloads all data
        if time > self.refreshTime {
            self.myTabBarController.viewControllers = self.getTabBarControllers()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func getTabBarControllers() -> [UIViewController] {
        let mainNavController = self.getTabBarNavController(viewController: VideoTableViewController(), icon: .tv, selectedIcon: .tvFill, tag: 0)
        let favoritesNavController = self.getTabBarNavController(viewController: FavoritesTableViewController(), icon: .heart, selectedIcon: .heartFill, tag:  1)
        let settingsNavController = self.getTabBarNavController(viewController: SettingsFormViewController(), icon: .settings, selectedIcon: .settingsFill, tag: 2)
        return [mainNavController, favoritesNavController, settingsNavController]
    }
    
    private func getTabBarNavController(viewController: UIViewController, icon: MyIconType, selectedIcon: MyIconType, tag: Int) -> UINavigationController {
        viewController.tabBarItem = Icons.getTabBarItem(icon: icon, selectedIcon: selectedIcon, tag: tag)
        viewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.isTranslucent = false
        return navController
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return .portrait
    }
}
