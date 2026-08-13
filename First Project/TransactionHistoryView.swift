//
//  TransactionHistoryView.swift
//  First Project
//
//  Created by Michael Bai on 8/12/26.
//

import SwiftUI

struct TransactionHistoryView: View {
    var budgetManager: BudgetManager
    var body: some View{
        List(budgetManager.transactions){transaction in
            VStack{
                Text(transaction.date, style:.date)
                Text("$\(transaction.amount, specifier: "%.2f")")
                if transaction.type == .expense{
                    Text("Expense")
                }
                else{
                    Text("Deposit")
                }
                Text(transaction.label ?? "No label")
                Text(transaction.category.displayName)  
            }
        }
    }
}
