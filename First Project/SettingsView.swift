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
    @State private var recurringExpensesInput: String = ""
    @State private var savingsPercentage: Double = 20.0 // Default value

    private var savingsAmount: Double{
        budgetManager.monthlyIncome * (savingsPercentage / 100)
    }

    var body: some View{
        Form{
            Section("Monthly Income"){
                TextField("0.0", text:$incomeInput)
            }
            Section("Recurring Expenses"){
                TextField("0.0", text:$recurringExpensesInput)
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
                       let expenses = Double(recurringExpensesInput) {
                        budgetManager.monthlyIncome = income
                        budgetManager.monthlyRecurringExpenses = expenses
                        budgetManager.monthlySavingsGoalDecimal = savingsPercentage / 100

                        dismiss()
                    }
                }
            }
        // Load all current values
        }.onAppear{
            incomeInput = String(budgetManager.monthlyIncome)
            recurringExpensesInput = String(budgetManager.monthlyRecurringExpenses)
            savingsPercentage = budgetManager.monthlySavingsGoalDecimal * 100
        }
    }
}

#Preview{
    SettingsView(budgetManager: BudgetManager())
}
