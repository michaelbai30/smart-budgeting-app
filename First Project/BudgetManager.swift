//
//  BudgetManager.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//
import Foundation
import SwiftUI
import SwiftData

@Model
class BudgetManager{
    init(monthlyIncome: Double=0.0, monthlySavingsGoalDecimal: Double=0.0, currentDiscretionaryFunds: Double=0.0, lastLoginDate: Date? = nil){
        self.monthlyIncome = monthlyIncome
        self.monthlySavingsGoalDecimal = monthlySavingsGoalDecimal
        self.currentDiscretionaryFunds = currentDiscretionaryFunds
        self.lastLoginDate = lastLoginDate
    }

    // User settings
    var monthlyIncome: Double = 0.0
    var monthlySavingsGoalDecimal: Double = 0.0

    var recurringExpenses: [RecurringExpense] = []

    // Account state
    var currentDiscretionaryFunds: Double = 0.0
    var lastLoginDate: Date?
    var transactions: [Transaction] = []

    // Derived vars
    // Computed so it's always in sync with whatever is in recurringExpenses
    var monthlyRecurringExpenses: Double {
        recurringExpenses.reduce(0) { $0 + $1.amount }
    }

    // How much is left after expenses and savings
    var monthlyDiscretionary: Double {monthlyIncome - monthlyRecurringExpenses - (monthlyIncome * monthlySavingsGoalDecimal)}
    var daysInCurrentMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
    }
    var dailyBudget: Double{monthlyDiscretionary / Double(daysInCurrentMonth)}

    // Expenses and savings are technically optional
    var isSetupComplete: Bool {
        monthlyIncome > 0
    }

    // --- Methods ---
    func checkAndAwardDailyBonus() -> Bool{
        // startOfDay returns the same day but standardized to midnight.
        let today = Calendar.current.startOfDay(for: Date())

        // If never logged in, or its a new day
        if let lastLogin = lastLoginDate{
            let lastDay = Calendar.current.startOfDay(for: lastLogin)
            
            // Its a new day. Give bonus.
            if today > lastDay{
                awardDailyBonus()
                return true
            }
        }
        // First time logging in
        else {
            awardDailyBonus()
            return true
        }
        
        // Already got today's bonus
        return false
    }
    
    private func awardDailyBonus(){
        currentDiscretionaryFunds += dailyBudget
        lastLoginDate = Date()
    }

    func logExpense(amount: Double, label: String?, category: TransactionCategory?){
        currentDiscretionaryFunds -= amount
        let transaction = Transaction(date: Date(), amount: amount, label: label, category: category ?? .misc, type: .expense)
        transactions.append(transaction)
    }

    func logDeposit(amount: Double){
        currentDiscretionaryFunds += amount
        let transaction = Transaction(date: Date(), amount: amount, label: "Deposit", type: .deposit)
        transactions.append(transaction)
    }

}
