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
    
    // Get Month and Day
    @State private var selectedMonth: Date = Date() // current month by default
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    var totalSpent: Double {
        budgetManager.transactions.filter{$0.type == .expense && Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)}.reduce(0){x, y in x + y.amount}
    }

    var spendingByCategory: [TransactionCategory: Double]{
        let expenses = budgetManager.transactions.filter{$0.type == .expense && Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)}
        let grouped = Dictionary(grouping: expenses, by: {$0.category})
        return grouped.mapValues{transactions in transactions.reduce(0){x, y in x+y.amount}}
    }

    var body: some View{
        VStack{
            Text("Spending Statistics").font(.title)
            
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
            Text("Total Spent in \(monthYearString): $\(totalSpent, specifier: "%.2f")")

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
}


