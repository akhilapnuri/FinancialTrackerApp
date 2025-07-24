import Foundation
import SwiftUI

// Add this enum at the top of the file, after the imports
enum TransactionWarning {
    case futureDated
    case unusuallyLarge(amount: Double)
    case duplicate
    
    var message: String {
        switch self {
        case .futureDated:
            return "This transaction is dated in the future"
        case .unusuallyLarge(let amount):
            return "This is an unusually large transaction (\(String(format: "%.2f", amount)))"
        case .duplicate:
            return "This appears to be a duplicate transaction"
        }
    }
}

class TransactionManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    private let saveKeyPrefix = "SavedTransactions_"
    private var currentUserEmail: String?
    private var timer: Timer?
    
    // Constants for validation
    private let largeTransactionThreshold: Double = 5000.0
    private let duplicateTimeWindow: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
    
    init() {
        // Get current user's email from UserDefaults
        currentUserEmail = UserDefaults.standard.string(forKey: "userEmail")
        loadTransactions()
        
        // Observe changes to userEmail in UserDefaults
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userEmailChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
        // Start timer to check for recurring transactions
        startRecurringTransactionTimer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }
    
    @objc private func userEmailChanged() {
        let newEmail = UserDefaults.standard.string(forKey: "userEmail")
        if newEmail != currentUserEmail {
            currentUserEmail = newEmail
            loadTransactions()
        }
    }
    
    private var saveKey: String {
        guard let email = currentUserEmail else { return saveKeyPrefix }
        return saveKeyPrefix + email
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions.remove(at: index)
            saveTransactions()
        }
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            saveTransactions()
        }
    }
    
    private func getRecurringTransactionsInRange(start: Date, end: Date, limitToToday: Bool = true) -> [Transaction] {
        var recurringTransactions: [Transaction] = []
        let calendar = Calendar.current
        let today = Date()
        
        print("\n=== Processing Recurring Transactions ===")
        print("Report date range: \(start) to \(end)")
        
        for transaction in transactions where transaction.isRecurring {
            print("\nChecking transaction: \(transaction.description)")
            print("Original date: \(transaction.date)")
            print("Recurrence interval: \(transaction.recurrenceInterval ?? 0) days")
            print("End date: \(transaction.recurrenceEndDate?.description ?? "none")")
            
            guard let interval = transaction.recurrenceInterval else {
                print("Skipping - No interval set")
                continue
            }
            
            // Normalize all dates to start of day for consistent comparison
            let normalizedStart = calendar.startOfDay(for: start)
            let normalizedEnd = calendar.startOfDay(for: end)
            let normalizedToday = calendar.startOfDay(for: today)
            let reportEndDate = limitToToday ? min(normalizedEnd, normalizedToday) : normalizedEnd
            
            // If transaction has an end date, check if it's relevant to our date range
            if let recurrenceEndDate = transaction.recurrenceEndDate {
                let normalizedRecurrenceEnd = calendar.startOfDay(for: recurrenceEndDate)
                print("Normalized recurrence end date: \(normalizedRecurrenceEnd)")
                
                // Skip if the recurrence end date is before our start date
                if normalizedRecurrenceEnd < normalizedStart {
                    print("Skipping - Recurrence end date is before report start date")
                    continue
                }
                
                // Use the earlier of the report end date or recurrence end date
                let effectiveEndDate = min(reportEndDate, normalizedRecurrenceEnd)
                print("Using effective end date: \(effectiveEndDate)")
                
                // Start from the first recurrence
                var currentDate = calendar.date(byAdding: .day, value: interval, to: transaction.date) ?? transaction.date
                currentDate = calendar.startOfDay(for: currentDate)
                
                while currentDate <= effectiveEndDate {
                    if currentDate >= normalizedStart {
                        print("Adding occurrence for date: \(currentDate)")
                        let recurringTransaction = Transaction(
                            id: UUID(),
                            date: currentDate,
                            amount: transaction.amount,
                            type: transaction.type,
                            category: transaction.category,
                            description: transaction.description,
                            notes: transaction.notes,
                            isRecurring: true,
                            recurrenceInterval: interval,
                            recurrenceEndDate: transaction.recurrenceEndDate
                        )
                        recurringTransactions.append(recurringTransaction)
                    }
                    
                    // Move to next occurrence
                    currentDate = calendar.date(byAdding: .day, value: interval, to: currentDate) ?? currentDate
                    currentDate = calendar.startOfDay(for: currentDate)
                }
            } else {
                // Handle transactions without end date
                var currentDate = calendar.date(byAdding: .day, value: interval, to: transaction.date) ?? transaction.date
                currentDate = calendar.startOfDay(for: currentDate)
                
                while currentDate <= reportEndDate {
                    if currentDate >= normalizedStart {
                        print("Adding occurrence for date: \(currentDate)")
                        let recurringTransaction = Transaction(
                            id: UUID(),
                            date: currentDate,
                            amount: transaction.amount,
                            type: transaction.type,
                            category: transaction.category,
                            description: transaction.description,
                            notes: transaction.notes,
                            isRecurring: true,
                            recurrenceInterval: interval,
                            recurrenceEndDate: transaction.recurrenceEndDate
                        )
                        recurringTransactions.append(recurringTransaction)
                    }
                    
                    // Move to next occurrence
                    currentDate = calendar.date(byAdding: .day, value: interval, to: currentDate) ?? currentDate
                    currentDate = calendar.startOfDay(for: currentDate)
                }
            }
        }
        
        print("\nTotal recurring transactions found: \(recurringTransactions.count)")
        return recurringTransactions
    }
    
    func getTransactionsByDateRange(start: Date, end: Date) -> [Transaction] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
        
        // Get regular transactions within the date range (including original recurring transactions)
        let regularTransactions = transactions.filter { transaction in
            let transactionDate = calendar.startOfDay(for: transaction.date)
            return transactionDate >= startOfDay && transactionDate <= endOfDay
        }
        
        // Get recurring transaction occurrences that fall within this date range
        let recurringTransactions = getRecurringTransactionsInRange(start: startOfDay, end: endOfDay, limitToToday: false)
        
        // Combine and sort all transactions
        return (regularTransactions + recurringTransactions).sorted { $0.date < $1.date }
    }
    
    func getTransactionsByCategory(_ category: TransactionCategory) -> [Transaction] {
        return transactions.filter { $0.category == category }
    }
    
    func getCurrentBalance() -> Double {
        let today = Date()
        
        // Get regular transactions up to today
        let regularTransactions = transactions.filter { $0.date <= today }
        
        // Get recurring transactions up to today (limiting to today)
        let recurringTransactions = getRecurringTransactionsInRange(start: today, end: today, limitToToday: true)
        
        // Calculate balance from all transactions
        let allTransactions = regularTransactions + recurringTransactions
        return allTransactions.reduce(0) { result, transaction in
            result + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    func getIncomeExpenseSummary() -> (income: Double, expense: Double) {
        let today = Date()
        
        // Get regular transactions up to today
        let regularTransactions = transactions.filter { $0.date <= today }
        
        // Get recurring transactions up to today (limiting to today)
        let recurringTransactions = getRecurringTransactionsInRange(start: today, end: today, limitToToday: true)
        
        // Calculate summary from all transactions
        let allTransactions = regularTransactions + recurringTransactions
        let income = allTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = allTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return (income, expense)
    }
    
    private func saveTransactions() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(transactions)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Error saving transactions: \(error)")
        }
    }
    
    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                transactions = try decoder.decode([Transaction].self, from: data)
            } catch {
                print("Error loading transactions: \(error)")
                transactions = []
            }
        } else {
            transactions = []
        }
    }
    
    func clearTransactions() {
        transactions = []
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
    
    private func startRecurringTransactionTimer() {
        // Check for recurring transactions every day at midnight
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let now = Date()
        guard let tomorrow = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) else { return }
        
        let timeInterval = tomorrow.timeIntervalSince(now)
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.checkAndCreateRecurringTransactions()
        }
    }
    
    private func checkAndCreateRecurringTransactions() {
        let calendar = Calendar.current
        let today = Date()
        
        for transaction in transactions where transaction.isRecurring {
            guard let interval = transaction.recurrenceInterval,
                  let lastDate = calendar.date(byAdding: .day, value: -interval, to: today) else { continue }
            
            // Check if we need to create a new recurring transaction
            if transaction.date <= lastDate {
                // Check if we've reached the end date
                if let endDate = transaction.recurrenceEndDate {
                    let normalizedToday = calendar.startOfDay(for: today)
                    let normalizedEndDate = calendar.startOfDay(for: endDate)
                    
                    if normalizedToday > normalizedEndDate {
                        print("Skipping creation of recurring transaction \(transaction.description) - Today \(normalizedToday) is after end date \(normalizedEndDate)")
                        continue
                    }
                }
                
                // Create new recurring transaction
                let newTransaction = Transaction(
                    amount: transaction.amount,
                    type: transaction.type,
                    category: transaction.category,
                    description: transaction.description,
                    notes: transaction.notes,
                    isRecurring: true,
                    recurrenceInterval: interval,
                    recurrenceEndDate: transaction.recurrenceEndDate
                )
                
                print("Creating new recurring transaction \(transaction.description) for date \(today)")
                addTransaction(newTransaction)
            }
        }
    }
    
    func validateTransaction(_ transaction: Transaction) -> [TransactionWarning] {
        var warnings: [TransactionWarning] = []
        
        // Check for future-dated transactions
        if transaction.date > Date() {
            warnings.append(.futureDated)
        }
        
        // Check for unusually large transactions
        if transaction.amount > largeTransactionThreshold {
            warnings.append(.unusuallyLarge(amount: transaction.amount))
        }
        
        // Check for duplicate transactions
        if isDuplicateTransaction(transaction) {
            warnings.append(.duplicate)
        }
        
        return warnings
    }
    
    private func isDuplicateTransaction(_ transaction: Transaction) -> Bool {
        let calendar = Calendar.current
        let transactionDate = calendar.startOfDay(for: transaction.date)
        
        return transactions.contains { existingTransaction in
            // Skip comparing with itself
            guard existingTransaction.id != transaction.id else { return false }
            
            let existingDate = calendar.startOfDay(for: existingTransaction.date)
            
            // Check if transactions are within 24 hours of each other
            let timeDifference = abs(existingDate.timeIntervalSince(transactionDate))
            guard timeDifference <= duplicateTimeWindow else { return false }
            
            // Check if amount, type, category, and description match
            return existingTransaction.amount == transaction.amount &&
                   existingTransaction.type == transaction.type &&
                   existingTransaction.category == transaction.category &&
                   existingTransaction.description == transaction.description
        }
    }
}
