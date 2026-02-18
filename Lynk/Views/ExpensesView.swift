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
    
    @State private var showAddSheet = false
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                summaryCard
                expensesList
            }
            .padding(.top)
            .premiumBackground()
            .navigationTitle("Expenses")
            .toolbar {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(Color.lynkMint)
                        .padding(8)
                        .background(Color.lynkCardDark)
                        .clipShape(Circle())
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddExpenseSheet()
                    .presentationDetents([.medium])
            }
        }
    }
    
    var summaryCard: some View {
        VStack(spacing: 8) {
            Text("TOTAL EXPENSES")
                .font(.caption)
                .fontWeight(.bold)
                .secondaryText()
                .tracking(1)
            
            Text(totalExpenses, format: .currency(code: "USD"))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .primaryText() // 👈 Fixed White Text Bug
        }
        .frame(maxWidth: .infinity)
        .padding(25)
        .luxuryCardStyle()
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var expensesList: some View {
        if expenses.isEmpty {
            ContentUnavailableView {
                Label("No Expenses", systemImage: "creditcard")
                    .foregroundStyle(Color.lynkMint)
            } description: {
                Text("Track your business costs here.")
                    .secondaryText()
            }
        } else {
            List {
                ForEach(expenses) { expense in
                    ExpenseRow(expense: expense)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(expense)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                    .primaryText() // 👈 Fixed White Text Bug
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .secondaryText()
            }
            Spacer()
            Text(expense.amount, format: .currency(code: "USD"))
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.lynkRed)
        }
        .padding()
        .luxuryCardStyle()
        .padding(.bottom, 8)
    }
}

// MARK: - Add Expense Sheet
struct AddExpenseSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var amount = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Expense Name", text: $title)
                    TextField("Amount ($)", text: $amount)
                        .keyboardType(.decimalPad)
                }
                // 👈 DELETED hardcoded dark background code here
            }
            // 👈 DELETED hardcoded dark background code here
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
                .foregroundStyle(Color.lynkMint)
            }
        }
    }
}
