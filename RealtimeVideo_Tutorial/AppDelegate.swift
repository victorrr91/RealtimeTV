//
//  AppDelegate.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var shouldSupportAllOrientation = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if shouldSupportAllOrientation {
            return [.portrait, .landscape]
        } else {
            return [.portrait]
        }
    }
}

