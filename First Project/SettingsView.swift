//
//  SettingsView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//

import SwiftUI

struct SettingsView: View{
    @Environment(\.dismiss) var dismiss
    var budgetManager: BudgetManager
    @State private var incomeInput: String = ""
    @State private var expensesInput: String = ""
    @State private var savingsInput: String = ""

    var body: some View{
        Form{
            Section(){
                TextField("Monthly Income", text:$incomeInput)
            }
            Section(){
                TextField("Fixed Expenses", text:$expensesInput)
            }
            Section(){
                TextField("Savings %", text:$savingsInput)
            }
            Section{
                Button("Save Changes"){
                    if let income = Double(incomeInput),
                       let expenses = Double(expensesInput),
                       let savings = Double(savingsInput){
                        budgetManager.monthlyIncome = income
                        budgetManager.monthlyFixedExpenses = expenses
                        budgetManager.monthlySavingsGoalDecimal = savings / 100
                        
                        dismiss()
                    }
                }
            }
        // Load all current values
        }.onAppear{
            incomeInput = String(budgetManager.monthlyIncome)
            expensesInput = String(budgetManager.monthlyFixedExpenses)
            savingsInput = String(budgetManager.monthlySavingsGoalDecimal * 100)
        }
    }
}
