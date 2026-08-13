//
//  OnboardingView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//
import SwiftUI

struct OnboardingView: View {
    var budgetManager: BudgetManager
    @State var incomeInput: String = ""
    @State var recurringExpensesInput: String = ""
    @State var savingsPercentage: Double = 20.0
    
    @State var currentStep: Int = 1 // Which screen am I on?
    
    var body: some View{
        if currentStep == 1 {
            VStack{
                Text("Step \(currentStep) out of 3")
                TextField("Enter your monthly income in dollars", text: $incomeInput)
                
                Button("Next"){
                    currentStep += 1
                }
            }
        }
        else if currentStep == 2 {
            VStack{
                Text("Step \(currentStep) out of 3")
                TextField("Enter your monthly recurring (fixed) expenses in dollars", text: $recurringExpensesInput)
                
                Button("Next"){
                    currentStep += 1
                }
            }
        }
        else if currentStep == 3{
            VStack{
                Text("Step \(currentStep) out of 3")
                VStack(alignment: .leading, spacing: 12){
                    Slider(value: $savingsPercentage, in: 0...100, step: 1)

                    Text("\(Int(savingsPercentage))%").font(.title2).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)

                    let savingsAmount = (Double(incomeInput) ?? 0) * (savingsPercentage / 100)

                    Text("You'll save $\(savingsAmount, specifier: "%.2f") per month!").font(.caption).foregroundStyle(.secondary)
                }

                Button("Next"){
                    if let income = Double(incomeInput), let recurringExpenses = Double(recurringExpensesInput) {
                        budgetManager.monthlyIncome = income
                        budgetManager.monthlyRecurringExpenses = recurringExpenses
                        budgetManager.monthlySavingsGoalDecimal = savingsPercentage / 100
                        currentStep += 1
                    }
                    else{
                        print("Invalid input")
                    }
                }
            }

        }
    }
}
#Preview{
    OnboardingView(budgetManager: BudgetManager())
}
