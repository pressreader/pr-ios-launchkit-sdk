//
//  ContentView.swift
//  LaunchKitDemo
//
//  Created by Vitali Bounine on 2025-03-28.
//  Copyright © 2025 PressReader. All rights reserved.
//

import SwiftUI
import PRAppLaunchKit

enum Scheme: String, CaseIterable, Identifiable {
    case pressreader, priphone, priphone4
    var id: Self { self }
}

struct ContentView: View {
    @State private var scheme = Scheme(rawValue: PRAppLaunchKit.defaultAppLaunch().scheme) ?? .pressreader
    @State private var isInstalled = PRAppLaunchKit.defaultAppLaunch().isAppInstalled()
    
    var body: some View {
        TabView {
            GiftRegView(scheme: $scheme, isInstalled: $isInstalled)
                .tabItem {
                    Label("Gift Access", systemImage: "gift")
                }
            
            GeneralCommandView(scheme: $scheme, isInstalled: $isInstalled)
                .tabItem {
                    Label("Deep Link", systemImage: "terminal")
                }
        }
        .onChange(of: scheme) { _, newValue in
            PRAppLaunchKit.defaultAppLaunch().scheme = newValue.rawValue
            isInstalled = PRAppLaunchKit.defaultAppLaunch().isAppInstalled()
        }
    }
}

#Preview {
    ContentView()
}
