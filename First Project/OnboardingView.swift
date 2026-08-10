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
    @State var fixedExpensesInput: String = ""
    @State var savingsPercentageStr: String = ""
    
    @State var currentStep: Int = 1 // Which screen am I on?
    
    var body: some View{
        if currentStep == 1 {
            VStack{
                Text("Step \(currentStep) out of 3")
                TextField("Enter your monthly income in dollars", text: $incomeInput)
                
                Button("Next"){
                    // TODO
                    currentStep += 1
                }
            }
        }
        else if currentStep == 2 {
            VStack{
                Text("Step \(currentStep) out of 3")
                TextField("Enter your monthly fixed expenses in dollars", text: $fixedExpensesInput)
                
                Button("Next"){
                    // TODO
                    currentStep += 1
                }
            }
        }
        else if currentStep == 3{
            VStack{
                Text("Step \(currentStep) out of 3")
                TextField("Enter the amount you want to save per month as a percentage of your income", text: $savingsPercentageStr)
                
                Button("Next"){
                    if let income = Double(incomeInput), let fixedExpenses = Double(fixedExpensesInput), let savingsPercentage = Double(savingsPercentageStr){
                        
                        budgetManager.monthlyIncome = income
                        budgetManager.monthlyFixedExpenses = fixedExpenses
                        budgetManager.monthlySavingsGoalDecimal = savingsPercentage / 100
                    }
                    else{
                        print("Invalid input")
                    }
                }
            }
            
        }
    }
}
