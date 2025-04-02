//
//  LaunchKitDemoApp.swift
//  LaunchKitDemo
//
//  Created by Vitali Bounine on 2025-03-28.
//  Copyright © 2025 PressReader. All rights reserved.
//

import SwiftUI
import PRAppLaunchKit

@main
struct LaunchKitDemoApp: App {
    init() {
        // Initialize PRAppLaunchKit
        let appLaunch = PRAppLaunchKit.defaultAppLaunch()
        appLaunch.subscriptionKey = "589dea2bda854d38bb296ec866f752ef"
        appLaunch.scheme = "pressreader"
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
