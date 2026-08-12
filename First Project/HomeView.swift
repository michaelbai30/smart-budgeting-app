//
//  HomeView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//

import SwiftUI

struct HomeView: View{

    var budgetManager: BudgetManager
    @State private var transactionMode: TransactionType = .expense
    @State private var amount: String = ""
    @State private var label: String = ""
    @State private var category: TransactionCategory? = nil

    @State private var showSettingsMenu: Bool = false

    // Get bonus alert
    @State private var showBonusAlert = false
    @State private var dailyBonusGetMessage = ""

    private var isAmountValid: Bool{
        if let value = Double(amount) {
            return value > 0
        }
        return false
    }

    var body: some View{
        VStack{
            // Show balance
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

            Picker("", selection: $transactionMode){
                Text("Expense").tag(TransactionType.expense)
                Text("Deposit").tag(TransactionType.deposit)
            }
            TextField(transactionMode == .expense ? "Enter amount to spend" : "Enter amount to deposit", text: $amount).onSubmit{ confirmTransaction() }
            if transactionMode == .expense{
                TextField("Enter name for transaction (optional)", text: $label)
                Picker("Category", selection: $category){
                    ForEach(TransactionCategory.allCases, id: \.self){cat in
                        Text(cat.displayName).tag(cat as TransactionCategory?)
                    }
                }
            }
            Button("Confirm"){
                confirmTransaction()
            }.disabled(!isAmountValid).opacity(isAmountValid ? 1.0 : 0.5)

            // Pushes the Transaction history view onto the stack
            NavigationLink("Transaction History"){
                TransactionHistoryView(budgetManager: budgetManager)
            }
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
    private func confirmTransaction(){
        if let value = Double(amount) {
            if transactionMode == .expense {
                budgetManager.logExpense(amount: value)
            }
            else {
                budgetManager.logDeposit(amount: value)
            }
            amount = ""
            label = ""
        }
    }
}
#Preview{
    HomeView(budgetManager: BudgetManager())
}
