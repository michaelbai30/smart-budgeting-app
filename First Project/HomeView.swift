//
//  HomeView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//

import SwiftUI
import ConfettiSwiftUI

struct HomeView: View{
    var budgetManager: BudgetManager
    
    @State private var alreadyClaimedBonus: Bool = false

    @State private var transactionMode: TransactionType = .expense
    @State private var amount: String = ""
    @State private var label: String = ""
    @State private var category: TransactionCategory = .misc

    @State private var showSettingsMenu: Bool = false
    @State private var showBonusAlert: Bool = false
    @State private var dailyBonusGetMessage: String = ""
    
    @State private var confettiTrigger: Int = 0
    
    var body: some View{
        VStack{
            // Show balance
            Text("Your money!").font(.largeTitle).fontWeight(.bold)
            if budgetManager.currentDiscretionaryFunds > 0.0{
                Text("$\(budgetManager.currentDiscretionaryFunds, specifier: "%.2f")").font(.system(size: 48, weight: .bold, design: .rounded)).foregroundStyle(.green)
            }
            else if budgetManager.currentDiscretionaryFunds < 0.0{
                Text("$\(budgetManager.currentDiscretionaryFunds, specifier: "%.2f")").font(.system(size: 48, weight: .bold, design: .rounded)).foregroundStyle(.red)
            }
            else{
                Text("$\(budgetManager.currentDiscretionaryFunds, specifier: "%.2f")").font(.system(size: 48, weight: .bold, design: .rounded)).foregroundStyle(.gray)
            }

            Divider().padding(.vertical)

            // Show and Check Daily Reward
            Text("Daily Reward: $\(budgetManager.dailyBudget, specifier: "%.2f")").fontWeight(.semibold)

            // Transactions
            Picker("", selection: $transactionMode){
                Text("Expense").tag(TransactionType.expense)
                Text("Deposit").tag(TransactionType.deposit)
            }
            TextField(transactionMode == .expense ? "Enter amount spent" : "Enter amount to deposit", text: $amount).onSubmit{ confirmTransaction() }

            if transactionMode == .expense{
                TextField("Enter name for transaction (optional)", text: $label)
                Picker("Category", selection: $category){
                    ForEach(TransactionCategory.allCases, id: \.self){cat in
                        Text(cat.displayName).tag(cat as TransactionCategory)
                    }
                }
            }
            Button("Confirm"){
                confirmTransaction()
            }.disabled(!isAmountValid).opacity(isAmountValid ? 1.0 : 0.5)
            
            NavigationLink("Transaction Statistics"){
                StatsView(budgetManager: budgetManager)
            }
            // Pushes the Transaction history view onto the stack
            NavigationLink("Transaction History"){
                TransactionHistoryView(budgetManager: budgetManager)
            }
            Button("Settings"){
                showSettingsMenu = true // trigger the sheet
            }.sheet(isPresented: $showSettingsMenu){
                SettingsView(budgetManager: budgetManager)
            }
            if alreadyClaimedBonus{
                Text("You already claimed today's bonus!")
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
        ).onAppear(){
            let didGetBonus = budgetManager.checkAndAwardDailyBonus()
            if didGetBonus {
                dailyBonusGetMessage = "You earned $\(String(format: "%.2f", budgetManager.dailyBudget)) to spend today!"
                showBonusAlert = true
                confettiTrigger += 1
                alreadyClaimedBonus = true
            }
        }.confettiCannon(trigger: $confettiTrigger, num: 50)
    }
    private func confirmTransaction(){
        if let value = Double(amount) {
            if transactionMode == .expense {
                budgetManager.logExpense(amount: value, label: label, category: category)
            }
            else {
                budgetManager.logDeposit(amount: value)
            }
            amount = ""
            label = ""
            category = .misc
        }
    }
    private var isAmountValid: Bool{
        if let value = Double(amount) {
            return value > 0
        }
        return false
    }
}
#Preview{
    HomeView(budgetManager: BudgetManager())
}
