//  LaunchKitDemoApp.swift
//  LaunchKitDemo
//
//  Created by Vitali Bounine on 2025-03-28.
//  Copyright © 2025 PressReader. All rights reserved.
//

import SwiftUI
import PRAppLaunchKit
import SwiftData
import CryptoKit

@main
struct LaunchKitDemoApp: App {
    var sharedModelContainer: ModelContainer
    
    init() {
        // Initialize PRAppLaunchKit
        let appLaunch = PRAppLaunchKit.defaultAppLaunch()
        appLaunch.subscriptionKey = "589dea2bda854d38bb296ec866f752ef"
        appLaunch.scheme = "pressreader"
        
        // ModelContainer setup
        do {
            sharedModelContainer = try ModelContainer(for: CommandPreset.self)
            // Check and populate or update data on app start
            checkAndPopulateOrUpdateInitialData(container: sharedModelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(self.sharedModelContainer)
    }
}

private
extension LaunchKitDemoApp {
    // Note: We use the JSON file's modification Date as a version marker ("hash")
    func checkAndPopulateOrUpdateInitialData(container: ModelContainer) {
        let defaults = UserDefaults.standard
        let storedOriginalJSONModificationDateKey = "originalJSONModificationDate"       // Last JSON modification time (hash) stored
        let jsonFileName = "deeplink-presets"
        let jsonExtension = "json"
        
        guard let jsonURL = Bundle.main.url(forResource: jsonFileName, withExtension: jsonExtension) else {
            print("Initial data file not found in bundle.")
            return
        }
        
        // Get current JSON file's modification date to use as hash
        guard let currentJSONDate = try? FileManager.default.attributesOfItem(atPath: jsonURL.path)[.modificationDate] as? Date else {
            print("Failed to get JSON file modification date.")
            
            return
        }
        
        let currentHash = currentJSONDate
        let lastStoredHash = defaults.object(forKey: storedOriginalJSONModificationDateKey) as? Date
        
        // If JSON file hash did not change since last load, no update needed
        guard currentHash != lastStoredHash else {
            print("JSON file hash matches the stored hash. No import/update needed.")
            
            return
        }
        
        do {
            // Load JSON data from the bundle
            let jsonItems = try loadInitialDataFromJSON(url: jsonURL)
            
            let context = ModelContext(container)
            
            // Compute set of names present in the JSON to detect removals
            let jsonNames = Set(jsonItems.map { $0.name })

            // If we have a previous hash, delete records that were last updated from that JSON
            // but are no longer present in the current JSON (by name)
            if let lastStoredHash {
                let deleteDescriptor = FetchDescriptor<CommandPreset>(
                    predicate: #Predicate { preset in
                        preset.updatedAt == lastStoredHash && !jsonNames.contains(preset.name)
                    }
                )
                // Fetch all candidates to delete
                let toDelete = try context.fetch(deleteDescriptor)
                for record in toDelete {
                    print ("Deleting record no longer present in JSON: \(record.name) - \(record.updatedAt))")
                    context.delete(record)
                }
            }
            
            // Iterate over JSON records and update/insert accordingly
            for jsonItem in jsonItems {
                // Fetch a single existing record by name
                let name = jsonItem.name
                var descriptor = FetchDescriptor<CommandPreset>(
                    predicate: #Predicate { $0.name == name }
                )
                descriptor.fetchLimit = 1

                let existingMatches = try context.fetch(descriptor)
                if let existingRecord = existingMatches.first {
                    // Record exists - decide if update or skip based on updatedAt and previous JSON hash
                    if existingRecord.updatedAt == lastStoredHash {
                        existingRecord.update(from: jsonItem, timestamp: currentHash)
                    }
                } else {
                    // Record does not exist - insert new with JSON mtime as updatedAt
                    let commandPreset = CommandPreset(from: jsonItem, timestamp: currentHash)
                    context.insert(commandPreset)
                }
            }
            
            // Save context changes
            try context.save()
            
            // Update user defaults with new hash
            defaults.set(currentHash, forKey: storedOriginalJSONModificationDateKey)
            
            print("Data import/update complete with JSON file modification time: \(currentHash)")
            
        } catch {
            print("Error during data check/import: \(error.localizedDescription)")
        }
    }
    
    /// Helper to load and decode the data from a specific URL
    func loadInitialDataFromJSON(url: URL) throws -> [Preset] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([Preset].self, from: data)
    }
}

