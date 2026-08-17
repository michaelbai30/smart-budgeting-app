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
        List(budgetManager.transactions.sorted(by: {$0.date > $1.date})){transaction in
            HStack{
                VStack(alignment: .leading){
                    Text(transaction.label ?? "No Label")
                    Text(transaction.date, style:.date).font(.caption).foregroundStyle(Color.secondary)
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text("$\(transaction.amount, specifier: "%.2f")").fontWeight(.semibold)
                    Text(transaction.category.displayName).font(.caption).foregroundStyle(Color.secondary)
                }
                
            }.listRowBackground(transaction.type == .expense ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
        }.navigationTitle(Text("Transaction History"))
    }
}

#Preview {
    TransactionHistoryView(budgetManager: BudgetManager())
}
