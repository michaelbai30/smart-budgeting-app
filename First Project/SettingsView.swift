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
    @State private var savingsPercentage: Double = 20.0 // Default value

    private var savingsAmount: Double{
        budgetManager.monthlyIncome * (savingsPercentage / 100)
    }

    var body: some View{
        Form{
            Section(){
                TextField("Monthly Income", text:$incomeInput)
            }
            Section(){
                TextField("Fixed Expenses", text:$expensesInput)
            }
            Section("Savings Goal"){
                VStack(alignment: .leading, spacing: 12){
                    // Slider
                    Slider(value: $savingsPercentage, in: 0...100, step: 1)

                    // Show percentage
                    Text("\(Int(savingsPercentage))%").font(.title2).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)
                    
                    // Show dollar amount
                    Text("You'll save $\(savingsAmount, specifier: "%.2f") per month!").font(.caption).foregroundStyle(.secondary)
                }
            }
            Section{
                Button("Save Changes"){
                    if let income = Double(incomeInput),
                       let expenses = Double(expensesInput) {
                        budgetManager.monthlyIncome = income
                        budgetManager.monthlyFixedExpenses = expenses
                        budgetManager.monthlySavingsGoalDecimal = savingsPercentage / 100

                        dismiss()
                    }
                }
            }
        // Load all current values
        }.onAppear{
            incomeInput = String(budgetManager.monthlyIncome)
            expensesInput = String(budgetManager.monthlyFixedExpenses)
            savingsPercentage = budgetManager.monthlySavingsGoalDecimal * 100
        }
    }
}

#Preview{
    SettingsView(budgetManager: BudgetManager())
}
