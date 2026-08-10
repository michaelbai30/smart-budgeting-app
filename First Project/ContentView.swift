//
//  ContentView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//
// Serves as the master coordinator
// Owns the database connection
// Gets and creates Budget Manager
// Routes views
// Pass BudgetManager down to child views

import SwiftUI
import SwiftData

struct ContentView: View {
    // @State: The data can change. When it changes, redraw the view. A property of the struct
    @Query private var budgetManagers: [BudgetManager]
    @Environment(\.modelContext) private var modelContext // Save to model
    
    private var budgetManager: BudgetManager{
        if let existing = budgetManagers.first{
            return existing
        }
        else{
            // No BudgetManager exists yet, create one
            let newManager = BudgetManager()
            modelContext.insert(newManager)
            return newManager
        }
    }
    var body: some View {
        if budgetManager.isSetupComplete{
            HomeView(budgetManager: budgetManager)
        }
        else{
            OnboardingView(budgetManager: budgetManager)
        }
    }
}
#Preview {
    ContentView()
}
