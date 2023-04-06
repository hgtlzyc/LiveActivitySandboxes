//
//  AppDelegate.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import UIKit
import ActivityKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        Task { @MainActor in
            await endAllLiveActivities()
        }
    }
}

private extension AppDelegate {
    func endAllLiveActivities() async {
        let finalState = WorkoutLiveActivityAttributes.ContentState.empthState
        let finalContent = ActivityContent(
            state: finalState, staleDate: Date()
        )
        for activity in Activity<WorkoutLiveActivityAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
        
        Log.info("End Previous Activities")
    }
}

