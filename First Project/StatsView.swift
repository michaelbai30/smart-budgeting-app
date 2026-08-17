//
//  StatsView.swift
//  First Project
//
//  Created by Michael Bai on 8/17/26.
//
import SwiftUI
import Charts

struct StatsView: View{
    var budgetManager: BudgetManager

    var totalSpent: Double {
        budgetManager.transactions.filter{$0.type == .expense}.reduce(0){x, y in x + y.amount}
    }

    var spendingByCategory: [TransactionCategory: Double]{
        let expenses = budgetManager.transactions.filter{$0.type == .expense}
        let grouped = Dictionary(grouping: expenses, by: {$0.category})
        return grouped.mapValues{transactions in transactions.reduce(0){x, y in x+y.amount}}
    }

    var body: some View{
        VStack{
            Text("Spending Statistics").font(.title)
            Text("Total Spent: $\(totalSpent, specifier: "%.2f")")
        }
        
        Chart{
            ForEach(spendingByCategory.sorted(by: {$0.value > $1.value}), id: \.key){category, amount in
                BarMark(
                    x: .value("Category", category.displayName),
                    y: .value("Spent", amount)
                )
            }
        }
    }
}


