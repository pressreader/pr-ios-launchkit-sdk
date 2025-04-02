//
//  ContentView.swift
//  LaunchKitDemo
//
//  Created by Vitali Bounine on 2025-03-28.
//  Copyright © 2025 PressReader. All rights reserved.
//

import SwiftUI

enum Scheme: String, CaseIterable, Identifiable {
    case pressreader, priphone, priphone4
    var id: Self { self }
}

struct ContentView: View {
    var body: some View {
        TabView {
            GiftRegView()
                .tabItem {
                    Label("Gift Access", systemImage: "gift")
                }
            
            GeneralCommandView()
                .tabItem {
                    Label("Deep Link", systemImage: "terminal")
                }
        }
    }
}

#Preview {
    ContentView()
}
