//
//  TransactionHistoryView.swift
//  First Project
//
//  Created by Michael Bai on 8/12/26.
//

import SwiftUI

struct TransactionHistoryView: View {
    var budgetManager: BudgetManager
    
    @State private var selectedMonth: Date = Date()
    
    var monthYearString: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    var transactionsByDate: [Date: [Transaction]]{
        let filteredTransactions = budgetManager.transactions.filter{Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)}
        return Dictionary(grouping: filteredTransactions, by: {Calendar.current.startOfDay(for: $0.date)})
    }
    
    var body: some View{
        VStack{
            HStack{
                Button("<"){
                    if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth){
                        selectedMonth = newMonth
                    }
                }
                Text(monthYearString)
                Button(">"){
                    if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth){
                        selectedMonth = newMonth
                    }
                }
                
            }
            List{
                ForEach(transactionsByDate.keys.sorted(by: {$0 > $1}), id: \.self){day in
                    Section(header: Text(day, style: .date)){
                        ForEach(transactionsByDate[day] ?? []){transaction in
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
                        }
                    }
                }
            }.navigationTitle(Text("Transaction History"))
        }
    }
}

#Preview {
    TransactionHistoryView(budgetManager: BudgetManager())
}
