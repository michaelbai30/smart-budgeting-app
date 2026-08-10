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
    
    init(monthlyIncome: Double=0.0, monthlyFixedExpenses: Double=0.0, monthlySavingsGoalDecimal: Double=0.0, currentDiscretionaryFunds: Double=0.0, lastLoginDate: Date? = nil){
        self.monthlyIncome = monthlyIncome
        self.monthlyFixedExpenses = monthlyFixedExpenses
        self.monthlySavingsGoalDecimal = monthlySavingsGoalDecimal
        self.currentDiscretionaryFunds = currentDiscretionaryFunds
        self.lastLoginDate = lastLoginDate
    }
    // User settings
    var monthlyIncome: Double = 0.0
    var monthlyFixedExpenses: Double = 0.0
    var monthlySavingsGoalDecimal: Double = 0.0
    
    // Account state
    var currentDiscretionaryFunds: Double = 0.0
    var lastLoginDate: Date?
    
    // How much is left after expenses and savings
    var monthlyDiscretionary: Double {monthlyIncome - monthlyFixedExpenses - (monthlyIncome * monthlySavingsGoalDecimal)}

    var dailyBudget: Double{monthlyDiscretionary / 30}
    
    var isSetupComplete: Bool {
        monthlyIncome > 0 && monthlyFixedExpenses > 0 && monthlySavingsGoalDecimal > 0
    }

    // METHODS
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

    func logExpense(amount: Double){
        currentDiscretionaryFunds -= amount
    }
}
