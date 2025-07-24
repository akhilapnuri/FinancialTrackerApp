//
//  AddTransactionView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/19/25.
//

import Foundation
import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var transactionManager: TransactionManager
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    @State private var amount = ""
    @State private var description = ""
    @State private var type: TransactionType = .expense
    @State private var category: TransactionCategory = .other
    @State private var date = Date()
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isRecurring = false
    @State private var recurrenceInterval = 30
    @State private var recurrenceEndDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var hasEndDate = false
    @State private var warnings: [TransactionWarning] = []
    @State private var showingWarnings = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                    
                    Picker("Type", selection: $type) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Category", selection: $category) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                if !warnings.isEmpty {
                    Section(header: Text("Warnings")) {
                        ForEach(warnings, id: \.message) { warning in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(warning.message)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section(header: Text("Recurring Transaction")) {
                    Toggle("Make this a recurring transaction", isOn: $isRecurring)
                    
                    if isRecurring {
                        Stepper("Repeat every \(recurrenceInterval) days", value: $recurrenceInterval, in: 1...365)
                        
                        Toggle("Set end date", isOn: $hasEndDate)
                        
                        if hasEndDate {
                            DatePicker("End Date", selection: $recurrenceEndDate, displayedComponents: .date)
                        }
                    }
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveTransaction()
                }
            )
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showingWarnings) {
                Alert(
                    title: Text("Transaction Warnings"),
                    message: Text(warnings.map { $0.message }.joined(separator: "\n")),
                    primaryButton: .default(Text("Save Anyway")) {
                        saveTransaction(ignoreWarnings: true)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onChange(of: amount) { _ in validateTransaction() }
            .onChange(of: description) { _ in validateTransaction() }
            .onChange(of: type) { _ in validateTransaction() }
            .onChange(of: category) { _ in validateTransaction() }
            .onChange(of: date) { _ in validateTransaction() }
        }
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
    }
    
    private func validateTransaction() {
        guard let amountDouble = Double(amount), amountDouble > 0 else { return }
        
        let transaction = Transaction(
            date: date,
            amount: amountDouble,
            type: type,
            category: category,
            description: description,
            notes: notes.isEmpty ? nil : notes,
            isRecurring: isRecurring,
            recurrenceInterval: isRecurring ? recurrenceInterval : nil,
            recurrenceEndDate: isRecurring && hasEndDate ? recurrenceEndDate : nil
        )
        
        warnings = transactionManager.validateTransaction(transaction)
    }
    
    private func saveTransaction(ignoreWarnings: Bool = false) {
        guard let amountDouble = Double(amount), amountDouble > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        guard !description.isEmpty else {
            alertMessage = "Please enter a description"
            showingAlert = true
            return
        }
        
        let transaction = Transaction(
            date: date,
            amount: amountDouble,
            type: type,
            category: category,
            description: description,
            notes: notes.isEmpty ? nil : notes,
            isRecurring: isRecurring,
            recurrenceInterval: isRecurring ? recurrenceInterval : nil,
            recurrenceEndDate: isRecurring && hasEndDate ? recurrenceEndDate : nil
        )
        
        if !warnings.isEmpty && !ignoreWarnings {
            showingWarnings = true
            return
        }
        
        transactionManager.addTransaction(transaction)
        presentationMode.wrappedValue.dismiss()
    }
}
