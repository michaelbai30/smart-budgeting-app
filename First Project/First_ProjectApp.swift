//
//  First_ProjectApp.swift
//  First Project
//
//  Created by Michael Bai on 8/9/26.
//

import SwiftUI
import SwiftData

@main
struct First_ProjectApp: App {
    
    var sharedModelContainer: ModelContainer = {

        // List of all @Model classes to be saved
        let schema = Schema([
            BudgetManager.self, // The class itself, not an instance
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        }
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(sharedModelContainer)
    }
}
