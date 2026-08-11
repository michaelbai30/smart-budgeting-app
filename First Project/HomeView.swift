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

    // Get bonus alert
    @State private var showBonusAlert = false
    @State private var dailyBonusGetMessage = ""

    private var isExpenseValid: Bool{
        guard let amount = Double(expenseAmount)
        else{
            return false
        }
        return amount > 0
    }
    
    var body: some View{
        VStack{
            Text("Your money!").font(.largeTitle).fontWeight(.bold)
            if budgetManager.currentDiscretionaryFunds > 0.0{
                Text("$\(budgetManager.currentDiscretionaryFunds, specifier: "%.2f")").font(.system(size: 48, weight: .bold, design: .rounded)).foregroundStyle(.green)
            }
            else{
                Text("$\(budgetManager.currentDiscretionaryFunds, specifier: "%.2f")").font(.system(size: 48, weight: .bold, design: .rounded)).foregroundStyle(.red)
            }
            Divider().padding(.vertical)
            Text("Daily Budget: $\(budgetManager.dailyBudget, specifier: "%.2f")").fontWeight(.semibold)
            Button("Check for Daily Reward"){
                let didGetBonus = budgetManager.checkAndAwardDailyBonus()
                if didGetBonus {
                    dailyBonusGetMessage = "You earned $\(String(format: "%.2f", budgetManager.dailyBudget)) to spend today!"
                    showBonusAlert = true
                }
                else{
                    dailyBonusGetMessage = "You already claimed your bonus today."
                    showBonusAlert = true
                }
            }
            TextField("Enter amount to spend", text:$expenseAmount).onSubmit{
                logExpense()
            }
            Button("Confirm"){
                logExpense()
            }.disabled(!isExpenseValid).opacity(isExpenseValid ? 1.0: 0.5)
            Button("Settings"){
                showSettingsMenu = true // trigger the sheet
            }.sheet(isPresented: $showSettingsMenu){
                SettingsView(budgetManager: budgetManager)
            }
        }.alert(
            "Daily Bonus",
            isPresented: $showBonusAlert,
            actions: {
                Button("Hooray! 🎉") {
                    showBonusAlert = false
                }
            },
            message: {
                Text(dailyBonusGetMessage)
            }
        )
       
    }
    private func logExpense(){
        if let amount = Double(expenseAmount){
            budgetManager.logExpense(amount: amount)
            expenseAmount = ""
        }
    }
}
#Preview{
    HomeView(budgetManager: BudgetManager())
}
