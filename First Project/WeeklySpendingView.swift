//
//  WeeklySpendingView.swift
//  First Project
//
//  Created by Michael Bai on 9/1/26.
//
import SwiftUI
struct WeeklySpendingView: View{
    var budgetManager: BudgetManager
    
    var weekDays: [Date]{
        let sunday = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!.start
        var days: [Date] = []

        for i in 0..<7{
            days.append(Calendar.current.date(byAdding: .day, value: i, to: sunday)!)
        }
        return days
    }

    var spendingPerDay: [Date: Double]{
        var res: [Date: Double] = [:]
        for day in weekDays {
            res[day] = budgetManager.transactions.filter { $0.type == .expense && Calendar.current.isDate($0.date, inSameDayAs: day) }.reduce(0) { x, y in x + y.amount }
        }
        return res
    }
    
    var weeklyAvgSpending: Double{
        let today = Date()
        var daysElapsedThisWeek: [Date] = []
        
        for day in weekDays {
            daysElapsedThisWeek.append(day)
            if Calendar.current.isDate(day, inSameDayAs: today){
                break
            }
        }
        
        let totalSpending = daysElapsedThisWeek.reduce(0) { x, y in x + (spendingPerDay[y] ?? 0) }
        return totalSpending / Double(daysElapsedThisWeek.count)
    }
    

    var body: some View {
        VStack{
            
            HStack{
                ForEach(weekDays, id: \.self){ day in
                    let formatter = DateFormatter()
                    let dayName = formatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: day) - 1]
                    let spent = spendingPerDay[day] ?? 0
                    let isInFuture = day > Date()
                    let percentageDiff = weeklyAvgSpending != 0 ? ((spent / weeklyAvgSpending) - 1) * 100 : 0.0
                    let percentColor: Color = percentageDiff > 0 ? .green : (percentageDiff < 0 ? .red : .gray)
                    let circleColor: Color = isInFuture ? Color.gray.opacity(0.2) : Color.blue.opacity(0.15)
                    VStack(spacing: 4){
                        Text(dayName)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(circleColor))

                        VStack(spacing: 2) {
                            if !isInFuture {
                                Text("$\(spent, specifier: "%.2f")").font(.caption)
                                Text("\(percentageDiff, specifier: "%.2f")%").font(.caption).foregroundStyle(percentColor)
                            }
                        }
                        .frame(height: 32) // Equal frame height so bubbles are aligned together
                    }.frame(maxWidth: .infinity) // Equal width for all 7 columns
                }
            }
        }.navigationTitle(Text("Weekly Spending Summary"))
    }
}
