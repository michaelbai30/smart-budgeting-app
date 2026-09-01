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
    @State private var showExpenseSheet: Bool = false
    @State private var showDepositSheet: Bool = false

    @State private var amount: String = ""
    @State private var label: String = ""
    @State private var category: TransactionCategory = .misc

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

            Text("Daily Reward: $\(budgetManager.dailyBudget, specifier: "%.2f")").fontWeight(.semibold)

            HStack(spacing: 16) {
                Button("Log Expense") {
                    showExpenseSheet = true
                }
                Button("Deposit Funds") {
                    showDepositSheet = true
                }
            }
            .padding(.top, 8)

            NavigationLink("Transaction Statistics"){
                StatsView(budgetManager: budgetManager)
            }
            NavigationLink("Transaction History"){
                TransactionHistoryView(budgetManager: budgetManager)
            }
            NavigationLink("Settings"){
                SettingsView(budgetManager: budgetManager)
            }

            if alreadyClaimedBonus{
                Text("You already claimed today's bonus!")
            }
        }
        // onDismiss runs when sheet closes for any reason (Cancel, swipe down, Confirm)
    .sheet(isPresented: $showExpenseSheet, onDismiss: resetForm) {
            NavigationStack {
                Form {
                    Section("Amount") {
                        TextField("Enter amount spent", text: $amount).keyboardType(.decimalPad)
                    }
                    Section("Details (Optional)") {
                        TextField("Label", text: $label)
                        Picker("Category", selection: $category) {
                            ForEach(TransactionCategory.allCases, id: \.self) { cat in
                                Text(cat.displayName).tag(cat)
                            }
                        }
                    }
                    Section {
                        Button("Confirm") {
                            confirmTransaction(as: .expense)
                            showExpenseSheet = false
                        }
                        .disabled(!isAmountValid)
                        .opacity(isAmountValid ? 1.0 : 0.5)
                    }
                }
                .navigationTitle("Log Expense")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showExpenseSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showDepositSheet, onDismiss: resetForm) {
            NavigationStack {
                Form {
                    Section("Amount") {
                        TextField("Enter amount to deposit", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    Section {
                        Button("Confirm") {
                            confirmTransaction(as: .deposit)
                            showDepositSheet = false
                        }
                        .disabled(!isAmountValid)
                        .opacity(isAmountValid ? 1.0 : 0.5)
                    }
                }
                .navigationTitle("Deposit Funds")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showDepositSheet = false
                        }
                    }
                }
            }
        }
        .alert(
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
        .onAppear(){
            let didGetBonus = budgetManager.checkAndAwardDailyBonus()
            if didGetBonus {
                dailyBonusGetMessage = "You earned $\(String(format: "%.2f", budgetManager.dailyBudget)) to spend today!"
                showBonusAlert = true
                confettiTrigger += 1
                alreadyClaimedBonus = true
            }
        }
        .confettiCannon(trigger: $confettiTrigger, num: 30)
    }

    private func confirmTransaction(as transactionMode: TransactionType) {
        if let value = Double(amount) {
            if transactionMode == .expense {
                budgetManager.logExpense(amount: value, label: label.isEmpty ? nil : label, category: category)
            }
            else {
                budgetManager.logDeposit(amount: value)
            }
            resetForm()
        }
    }

    private func resetForm() {
        amount = ""
        label = ""
        category = .misc
    }

    // Guards against empty string or non-numeric input
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
