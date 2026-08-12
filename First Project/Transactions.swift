//
//  Transactions.swift
//  First Project
//
//  Created by Michael Bai on 8/12/26.
//
import Foundation
import SwiftData

enum TransactionType: Codable{
    case expense
    case deposit
}

enum TransactionCategory: CaseIterable, Codable{
    case groceries
    case dining
    case entertainment
    case transportation
    case housing
    case utilities
    case insurance
    case other
    
    var displayName: String{
        switch self{
        case .groceries: return "Groceries"
        case .dining: return "Dining"
        case .entertainment: return "Entertainment"
        case .transportation: return "Transportation"
        case .housing: return "Housing"
        case .utilities: return "Utilities"
        case .insurance: return "Insurance"
        case .other: return "Other"
        }
    }
}

@Model
class Transaction{
    var date: Date
    var amount: Double
    var label: String?
    var category: TransactionCategory?
    var type: TransactionType
    
    init(date: Date, amount: Double, label: String? = nil, category: TransactionCategory? = nil, type: TransactionType) {
        self.date = date
        self.amount = amount
        self.label = label
        self.category = category
        self.type = type
    }
}

