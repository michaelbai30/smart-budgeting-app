//
//  RecurringExpense.swift
//  First Project
//
//  Created by Michael Bai on 8/25/26.
//

import Foundation
import SwiftData

@Model
class RecurringExpense {
    var name: String
    var amount: Double

    init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
    }
}

struct CustomExpenseEntry: Identifiable {
    let id: UUID
    var name: String
    var amount: String

    init(name: String = "", amount: String = "") {
        self.id = UUID()
        self.name = name
        self.amount = amount
    }
}

// Shared by OnboardingView and SettingsView
let presetExpenseCategories = [
    "Rent/Mortgage", "Car Payment", "Car Insurance",
    "Health Insurance", "Internet", "Phone Bill",
    "Electricity", "Gym Membership", "Streaming Services", "Student Loans"
]
