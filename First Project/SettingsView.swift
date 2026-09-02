//
//  SettingsView.swift
//  First Project
//
//  Created by Michael Bai on 8/10/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    var budgetManager: BudgetManager

    @State private var incomeInput: String = ""
    @State private var savingsPercentage: Double = 20.0
    @State private var presetAmounts: [String: String] = [:]
    @State private var customEntries: [CustomExpenseEntry] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private var previewIncome: Double { Double(incomeInput) ?? 0 }

    private var previewExpensesTotal: Double {
        var total = 0.0
        for preset in presetExpenseCategories {
            if let amountStr = presetAmounts[preset], let amount = Double(amountStr) {
                total += amount
            }
        }
        for entry in customEntries {
            if let amount = Double(entry.amount){
                total += amount
            }
        }
        return total
    }
    private var previewMonthly: Double {
        previewIncome - previewExpensesTotal - (previewIncome * savingsPercentage / 100)
    }

    private var previewDaily: Double {
        let days = Double(Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30)
        return previewMonthly / days
    }

    private var budgetHealthColor: Color {
        if previewDaily > 20{
            return .green
        }
        if previewDaily > 5 {
            return .orange
        }
        return .red
    }
    private var savingsAmount: Double {
        previewIncome * (savingsPercentage / 100)
    }

    var body: some View {
        Form {
            Section("Monthly Income") {
                TextField("", text: $incomeInput)
                    .keyboardType(.decimalPad)
            }

            Section("Savings Goal") {
                VStack(alignment: .leading, spacing: 12) {
                    Slider(value: $savingsPercentage, in: 0...100, step: 1)
                    Text("\(Int(savingsPercentage))%").font(.title2).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)
                    Text("You'll save $\(savingsAmount, specifier: "%.2f") per month.").font(.caption).foregroundStyle(.secondary)

                    Divider()

                    if previewIncome > 0 {
                        if previewDaily > 0 {
                            Text("You'll have $\(previewMonthly, specifier: "%.2f")/month ($\(previewDaily, specifier: "%.2f")/day) to spend freely.").fontWeight(.semibold).foregroundStyle(budgetHealthColor)
                        }
                        else {
                            Text("Your expenses and savings goal exceed your income. Lower your savings rate or reduce your expenses.").foregroundStyle(.red).font(.caption)
                        }
                    }
                }
            }

            Section {
                ForEach(presetExpenseCategories, id: \.self) { preset in
                    HStack {
                        Text(preset)
                        Spacer()
                        TextField("0.00", text: Binding(
                            get: { presetAmounts[preset] ?? "" },
                            set: { presetAmounts[preset] = $0 }
                        ))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recurring Expenses")
                    Text("Leave blank for any that don't apply to you.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.none)
                }
            }

            Section("Custom Expenses") {
                ForEach($customEntries) { $entry in
                    HStack {
                        TextField("Name", text: $entry.name)
                        Spacer()
                        TextField("0.00", text: $entry.amount)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                    }
                }
                .onDelete { customEntries.remove(atOffsets: $0) }
                Button("+ Add Custom") {
                    customEntries.append(CustomExpenseEntry())
                }
            }

            
        }
        .onAppear { loadCurrentValues() }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveChanges() }
                    .disabled(previewIncome > 0 && previewDaily <= 0)
            }
        }
        .navigationTitle("Settings")
        .alert("Invalid Input", isPresented: $showErrorAlert) {
            Button("OK") { showErrorAlert = false }
        } message: {
            Text(errorMessage)
        }
    }

    // Runs once when the view appears to pre-fill the form from saved data
    private func loadCurrentValues() {
        incomeInput = String(budgetManager.monthlyIncome)
        savingsPercentage = budgetManager.monthlySavingsGoalDecimal * 100
        for expense in budgetManager.recurringExpenses {
            if presetExpenseCategories.contains(expense.name) {
                presetAmounts[expense.name] = String(expense.amount)
            }
            else {
                customEntries.append(CustomExpenseEntry(name: expense.name, amount: String(expense.amount)))
            }
        }
    }

    // Returns nil if all inputs are valid, or an error msg
    private func validateInputs() -> String? {
        guard let income = Double(incomeInput), income > 0 else {
            return "Please enter a valid income greater than $0."
        }
        for preset in presetExpenseCategories {
            if let amountStr = presetAmounts[preset], !amountStr.isEmpty {
                guard let amount = Double(amountStr), amount >= 0 else {
                    return "\"\(preset)\" has an invalid amount. Enter an amount ≥ 0 or leave it blank."
                }
            }
        }
        for entry in customEntries {
            if !entry.amount.isEmpty {
                guard let amount = Double(entry.amount), amount >= 0 else {
                    let name = entry.name.isEmpty ? "a custom expense" : "\"\(entry.name)\""
                    return "\(name) has an invalid amount. Enter an amount >= 0"
                }
            }
        }
        return nil
    }

    private func saveChanges() {
        if let error = validateInputs() {
            errorMessage = error
            showErrorAlert = true
            return
        }
        let income = Double(incomeInput)!
        budgetManager.monthlyIncome = income
        budgetManager.monthlySavingsGoalDecimal = savingsPercentage / 100
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
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    SettingsView(budgetManager: BudgetManager())
}
