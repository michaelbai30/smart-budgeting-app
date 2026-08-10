//
//  HomeView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//

import SwiftUI

struct HomeView: View{
    var budgetManager: BudgetManager
    @State private var expenseAmount: String = ""
    @State private var showSettingsMenu: Bool = false
    
    var body: some View{
        VStack{
            Text("Balance: $\(budgetManager.currentDiscretionaryFunds)")
            Button("Check for Daily Reward"){
                let didGetBonus = budgetManager.checkAndAwardDailyBonus()
                if didGetBonus {
                    print("didGetBonus: \(didGetBonus)")
                }
            }

            TextField("Enter amount to spend", text:$expenseAmount).onSubmit{
                logExpense()
            }
            Button("Confirm"){
                logExpense()
            }
            Button("Settings"){
                showSettingsMenu = true // trigger the sheet
            }.sheet(isPresented: $showSettingsMenu){
                SettingsView(budgetManager: budgetManager)
            }
        }
    }

    private func logExpense(){
        if let amount = Double(expenseAmount){
            budgetManager.logExpense(amount: amount)
            expenseAmount = ""
        }
    }
}
