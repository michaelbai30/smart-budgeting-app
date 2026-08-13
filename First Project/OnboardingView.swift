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
    @State var errorMessage: String = ""
    @State var showErrorAlert: Bool = false

    private func validateDollarInput(input: String) -> Bool{
        if let doubleInput = Double(input){
            return doubleInput >= 0.0
        }
        return false
    }
    
    var body: some View{
        VStack{
            if currentStep == 1 {
                Text("Welcome to Smart Budgeting!")
                Button("Next"){
                    currentStep += 1
                }
            }
            if currentStep == 2 {
                VStack{
                    Text("Step \(currentStep) out of 3")
                    TextField("Enter your monthly income in dollars", text: $incomeInput)
                    Button("Next"){
                        if validateDollarInput(input: incomeInput){
                            currentStep += 1
                        }
                        else{
                            errorMessage = "Please enter a validate dollar amount >= 0"
                            showErrorAlert = true
                        }
                    }
                }
            }
            else if currentStep == 3 {
                VStack{
                    Text("Step \(currentStep) out of 3")
                    TextField("Enter your monthly recurring (fixed) expenses in dollars", text: $recurringExpensesInput)
                    
                    Button("Next"){
                        if validateDollarInput(input: recurringExpensesInput){
                            currentStep += 1
                        }
                        else{
                            errorMessage = "Please enter a validate dollar amount >= 0"
                            showErrorAlert = true
                        }
                    }
                }
            }
            else if currentStep == 4{
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
        }.alert("Invalid Input", isPresented: $showErrorAlert){
            Button("OK"){showErrorAlert = false}
        }
        message:{Text(errorMessage)}
    }
}

#Preview{
    OnboardingView(budgetManager: BudgetManager())
}
