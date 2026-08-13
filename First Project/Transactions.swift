//
//  Transactions.swift
//  First Project
//
//  Created by Michael Bai on 8/12/26.
//
import Foundation
import SwiftData

enum TransactionType: String, Codable{
    case expense
    case deposit
}

enum TransactionCategory: String, CaseIterable, Codable{
    case misc
    case groceries
    case dining
    case entertainment
    case transportation
    case housing
    case utilities
    case insurance
    
    var displayName: String{
        switch self{
            case .misc: return "Misc."
            case .groceries: return "Groceries"
            case .dining: return "Dining"
            case .entertainment: return "Entertainment"
            case .transportation: return "Transportation"
            case .housing: return "Housing"
            case .utilities: return "Utilities"
            case .insurance: return "Insurance"
        }
    }
}

@Model
class Transaction{
    var date: Date
    var amount: Double
    var label: String?
    var category: TransactionCategory
    var type: TransactionType
    
    init(date: Date, amount: Double, label: String? = nil, category: TransactionCategory = .misc, type: TransactionType) {
        self.date = date
        self.amount = amount
        self.label = label
        self.category = category
        self.type = type
    }
}
