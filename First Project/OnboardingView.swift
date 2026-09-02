//
//  OnboardingView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//
import SwiftUI
import SwiftData

struct OnboardingView: View {
    var budgetManager: BudgetManager
    @Environment(\.modelContext) private var modelContext

    @State var incomeInput: String = ""
    @State var savingsPercentage: Double = 20.0
    @State var presetAmounts: [String: String] = [:]
    @State var customEntries: [CustomExpenseEntry] = []

    @State var currentStep: Int = 1
    @State var errorMessage: String = ""
    @State var showErrorAlert: Bool = false

    private var previewIncome: Double { Double(incomeInput) ?? 0 }
    // monthlyRecurringExpenses reads from budgetManager
    // Expenses saved in step 3 are factored into the preview
    private var previewMonthly: Double {
        previewIncome - budgetManager.monthlyRecurringExpenses - (previewIncome * savingsPercentage / 100)
    }
    private var previewDaily: Double {
        let days = Double(Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30) // from Calendar
        return previewMonthly / days
    }
    
    // User feedback for a what an acceptable daily budget is, in my opinion.
    private var budgetHealthColor: Color {
        if previewDaily > 20 {
            return .green
        }
        if previewDaily > 5 {
            return .orange
        }
        return .red
    }

    var body: some View {
        VStack {
            if currentStep == 1 {
                Text("Welcome to Smart Budgeting!")
                Button("Next") {
                    currentStep += 1
                }
            }
            if currentStep == 2 {
                VStack {
                    Text("Step 1 of 3")
                    TextField("Enter your monthly income in dollars", text: $incomeInput)
                        .keyboardType(.decimalPad)
                    Button("Next") {
                        if let income = Double(incomeInput), income > 0 {
                            currentStep += 1
                        } else {
                            errorMessage = "Please enter a valid income greater than $0."
                            showErrorAlert = true
                        }
                    }
                }
            }
            else if currentStep == 3 {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Step 2 of 3").frame(maxWidth: .infinity, alignment: .center)

                        Text("Recurring Expenses").font(.headline)

                        Text("Enter your fixed monthly expenses below. Leave blank for anything that doesn't apply.").font(.caption).foregroundStyle(.secondary)

                        ForEach(presetExpenseCategories, id: \.self) { preset in
                            HStack {
                                Text(preset)
                                Spacer()
                                // Custom binding because presetAmounts[preset] returns Optional string
                                TextField("0.00", text: Binding(
                                    get: { presetAmounts[preset] ?? "" },
                                    set: { presetAmounts[preset] = $0 }
                                ))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            }
                            Divider()
                        }

                        Text("Custom Expenses")
                            .font(.headline)
                            .padding(.top, 8)

                        ForEach($customEntries) {$entry in
                            HStack {
                                TextField("Name", text: $entry.name)
                                Spacer()
                                TextField("0.00", text: $entry.amount)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 80)
                            }
                            Divider()
                        }

                        Button("+ Add Custom") {
                            customEntries.append(CustomExpenseEntry())
                        }

                        Button("Next") {
                            saveExpensesAndAdvance()
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            else if currentStep == 4 {
                VStack {
                    Text("Step 3 of 3")
                    VStack(alignment: .leading, spacing: 12) {
                        Slider(value: $savingsPercentage, in: 0...100, step: 1)

                        Text("\(Int(savingsPercentage))%").font(.title2).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)

                        let savingsAmount = previewIncome * (savingsPercentage / 100)
                        Text("You'll save $\(savingsAmount, specifier: "%.2f") per month!").font(.caption).foregroundStyle(.secondary)

                        Divider()

                        if previewDaily > 0 {
                            Text("You'll have $\(previewMonthly, specifier: "%.2f")/month ($\(previewDaily, specifier: "%.2f")/day) to spend freely.")
                                .fontWeight(.semibold)
                                .foregroundStyle(budgetHealthColor)
                        }
                        else {
                            Text("Your expenses and savings goal exceed your income. Please lower your savings rate to continue.")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }

                    Button("Finish") {
                        if let income = Double(incomeInput), income > 0 {
                            budgetManager.monthlyIncome = income
                            budgetManager.monthlySavingsGoalDecimal = savingsPercentage / 100
                            try? modelContext.save() // Manually call save
                            currentStep += 1
                        }
                        else {
                            errorMessage = "An error occurred. Please try again."
                            showErrorAlert = true
                        }
                    }.disabled(previewDaily <= 0)
                    .opacity(previewDaily <= 0 ? 0.5 : 1.0)
                }
            }
        }
        .alert("Invalid Input", isPresented: $showErrorAlert) {
            Button("OK") { showErrorAlert = false }
        }
        message: {
            Text(errorMessage)
        }
    }

    private func saveExpensesAndAdvance() {
        for preset in presetExpenseCategories {
            if let amountStr = presetAmounts[preset], !amountStr.isEmpty {
                guard let amount = Double(amountStr), amount >= 0
                else {
                    errorMessage = "\"\(preset)\" has an invalid amount. Enter an amount ≥ 0 or leave it blank."
                    showErrorAlert = true
                    return
                }
            }
        }
        for entry in customEntries {
            if !entry.amount.isEmpty {
                guard let amount = Double(entry.amount), amount >= 0
                else {
                    let name = entry.name.isEmpty ? "a custom expense" : "\"\(entry.name)\""
                    errorMessage = "\(name) has an invalid amount. Enter an amount ≥ 0."
                    showErrorAlert = true
                    return
                }
            }
        }
        for expense in budgetManager.recurringExpenses {
            modelContext.delete(expense)
        }
        budgetManager.recurringExpenses.removeAll()
        for preset in presetExpenseCategories {
            if let amountStr = presetAmounts[preset], let amount = Double(amountStr), amount > 0 {
                let expense = RecurringExpense(name: preset, amount: amount)
                modelContext.insert(expense)
                budgetManager.recurringExpenses.append(expense)
            }
        }
        for entry in customEntries {
            if !entry.name.isEmpty, let amount = Double(entry.amount), amount > 0 {
                let expense = RecurringExpense(name: entry.name, amount: amount)
                modelContext.insert(expense)
                budgetManager.recurringExpenses.append(expense)
            }
        }
        currentStep += 1
    }
}

#Preview {
    OnboardingView(budgetManager: BudgetManager())
}
