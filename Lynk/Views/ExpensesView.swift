//
//  ExpensesView.swift
//  Lynk
//
//  Created by gülçin çetin on 4.02.2026.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAddSheet = false
    
    // Calculate Total Expenses
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Summary Card
                VStack(spacing: 5) {
                    Text("Total Expenses")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text(totalExpenses, format: .currency(code: "USD"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                .cornerRadius(16)
                .padding()
                
                // Expense List
                if expenses.isEmpty {
                    ContentUnavailableView("No Expenses", systemImage: "creditcard", description: Text("Track your business costs here."))
                } else {
                    List {
                        ForEach(expenses) { expense in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(expense.title)
                                        .font(.headline)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Text(expense.amount, format: .currency(code: "USD"))
                                    .bold()
                                    .foregroundStyle(.red) // Red for "Money Out"
                            }
                            .listRowBackground(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(expenses[index])
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .premiumBackground()
            .navigationTitle("Expenses")
            .toolbar {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(Color.lynkYellow)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddExpenseSheet()
                    .presentationDetents([.medium])
            }
        }
    }
}

// Simple Sheet to Add Expense
struct AddExpenseSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var amount = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Expense Name (e.g. Hosting)", text: $title)
                TextField("Amount ($)", text: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Expense")
            .toolbar {
                Button("Save") {
                    if let value = Double(amount) {
                        let expense = Expense(title: title, amount: value, date: Date(), category: "General")
                        modelContext.insert(expense)
                        dismiss()
                    }
                }
                .disabled(title.isEmpty || amount.isEmpty)
            }
        }
    }
}
