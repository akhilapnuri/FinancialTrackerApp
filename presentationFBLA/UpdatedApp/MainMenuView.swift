import SwiftUI
import Charts

// Define app-wide colors
struct AppColors {
    static let primary = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let secondary = Color(red: 0.9, green: 0.4, blue: 0.3)
    static let navyBlue = Color(red: 0.0, green: 0.0, blue: 0.5)
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    // Dynamic colors that adapt to dark mode
    static var background: Color {
        Color(uiColor: .systemBackground)
    }
    
    static var cardBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    
    static var textPrimary: Color {
        Color(uiColor: .label)
    }
    
    static var textSecondary: Color {
        Color(uiColor: .secondaryLabel)
    }
}

// Add this new struct after AppColors
struct HeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.navyBlue)
    }
}

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var showingProfile = false
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Transactions Tab
            NavigationView {
                TransactionListView(transactionManager: appState.transactionManager)
                    .navigationBarItems(trailing: profileButton)
            }
            .tabItem {
                Label("Transactions", systemImage: "list.bullet")
            }
            .tag(0)
            
            // Financial Overview Tab
            NavigationView {
                FinancialOverviewView(transactionManager: appState.transactionManager)
                    .navigationBarItems(trailing: profileButton)
            }
            .tabItem {
                Label("Overview", systemImage: "chart.pie")
            }
            .tag(1)
            
            // Reports Tab
            NavigationView {
                ReportsView(transactionManager: appState.transactionManager)
                    .navigationBarItems(trailing: profileButton)
            }
            .tabItem {
                Label("Reports", systemImage: "doc.text")
            }
            .tag(2)
            
            // Search Tab
            NavigationView {
                SearchView(transactionManager: appState.transactionManager)
                    .navigationBarItems(trailing: profileButton)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(3)
            
            // More Info Tab
            NavigationView {
                MoreInfoView()
                    .navigationBarItems(trailing: profileButton)
            }
            .tabItem {
                Label("More", systemImage: "info.circle")
            }
            .tag(4)
        }
        .accentColor(AppColors.primary)
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingProfile) {
            NavigationView {
                ProfileView(isLoggedIn: $isLoggedIn)
                    .environmentObject(appState)
                    .background(AppColors.background)
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var profileButton: some View {
        Button(action: {
            showingProfile = true
        }) {
            Image(systemName: "person.circle.fill")
                .imageScale(.large)
                .foregroundColor(AppColors.primary)
        }
    }
}

struct TransactionListView: View {
    @ObservedObject var transactionManager: TransactionManager
    @State private var showingAddTransaction = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Transactions")
            
            List {
                ForEach(transactionManager.transactions) { transaction in
                    TransactionRow(transaction: transaction, transactionManager: transactionManager)
                        .listRowBackground(AppColors.cardBackground)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 8)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        transactionManager.deleteTransaction(transactionManager.transactions[index])
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTransaction = true }) {
                    Label("Add Transaction", systemImage: "plus.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(transactionManager: transactionManager)
                .background(AppColors.background)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    @ObservedObject var transactionManager: TransactionManager
    @EnvironmentObject var appState: AppState
    @State private var showingEditSheet = false
    
    var formattedAmount: String {
        let formatter = NumberFormatter.currencyFormatter(currencyCode: appState.selectedCurrency)
        return formatter.string(from: NSNumber(value: transaction.amount)) ?? "\(appState.getCurrencySymbol())\(transaction.amount)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.description)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(transaction.category.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text(formattedAmount)
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? AppColors.success : AppColors.error)
                
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .imageScale(.large)
                }
                .padding(.leading, 8)
            }
            
            Text(transaction.date, style: .date)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingEditSheet) {
            EditTransactionView(transactionManager: transactionManager, transaction: transaction)
                .background(AppColors.background)
        }
    }
}

struct EditTransactionView: View {
    @ObservedObject var transactionManager: TransactionManager
    let transaction: Transaction
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String
    @State private var description: String
    @State private var type: TransactionType
    @State private var category: TransactionCategory
    @State private var date: Date
    @State private var notes: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isRecurring: Bool
    @State private var recurrenceInterval: Int
    @State private var recurrenceEndDate: Date
    @State private var hasEndDate: Bool
    
    init(transactionManager: TransactionManager, transaction: Transaction) {
        self.transactionManager = transactionManager
        self.transaction = transaction
        _amount = State(initialValue: String(format: "%.2f", transaction.amount))
        _description = State(initialValue: transaction.description)
        _type = State(initialValue: transaction.type)
        _category = State(initialValue: transaction.category)
        _date = State(initialValue: transaction.date)
        _notes = State(initialValue: transaction.notes ?? "")
        _isRecurring = State(initialValue: transaction.isRecurring)
        _recurrenceInterval = State(initialValue: transaction.recurrenceInterval ?? 30)
        _recurrenceEndDate = State(initialValue: transaction.recurrenceEndDate ?? Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date())
        _hasEndDate = State(initialValue: transaction.recurrenceEndDate != nil)
    }
    
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
            .navigationTitle("Edit Transaction")
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
        }
    }
    
    private func saveTransaction() {
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
        
        let updatedTransaction = Transaction(
            id: transaction.id,
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
        
        transactionManager.updateTransaction(updatedTransaction)
        presentationMode.wrappedValue.dismiss()
    }
}

struct FinancialOverviewView: View {
    @ObservedObject var transactionManager: TransactionManager
    @EnvironmentObject var appState: AppState
    
    var formattedBalance: String {
        let formatter = NumberFormatter.currencyFormatter(currencyCode: appState.selectedCurrency)
        return formatter.string(from: NSNumber(value: transactionManager.getCurrentBalance())) ?? "\(appState.getCurrencySymbol())\(transactionManager.getCurrentBalance())"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Financial Overview")
            
            ScrollView {
                VStack(spacing: 20) {
                    // Current Balance Card
                    VStack(spacing: 12) {
                        Text("Current Balance")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formattedBalance)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(transactionManager.getCurrentBalance() >= 0 ? AppColors.success : AppColors.error)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Income vs Expenses Card
                    VStack(spacing: 12) {
                        Text("Income vs Expenses")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        let summary = transactionManager.getIncomeExpenseSummary()
                        HStack(spacing: 30) {
                            VStack(spacing: 8) {
                                Text("Income")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text(String(format: "\(appState.getCurrencySymbol())%.2f", summary.income))
                                    .font(.title2)
                                    .foregroundColor(AppColors.success)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(spacing: 8) {
                                Text("Expenses")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text(String(format: "\(appState.getCurrencySymbol())%.2f", summary.expense))
                                    .font(.title2)
                                    .foregroundColor(AppColors.error)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Spending Analysis Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending Analysis")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        CategoryPieChart(transactions: transactionManager.transactions)
                            .frame(height: 250)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryPieChart: View {
    let transactions: [Transaction]
    
    var categoryData: [(category: String, amount: Double)] {
        var categoryTotals: [TransactionCategory: Double] = [:]
        
        for transaction in transactions where transaction.type == .expense {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        return categoryTotals.map { (category: $0.key.rawValue.capitalized, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack {
            if categoryData.isEmpty {
                Text("No expense data available")
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(categoryData, id: \.category) { data in
                        SectorMark(
                            angle: .value("Amount", data.amount),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", data.category))
                    }
                }
                .chartLegend(position: .bottom)
            }
        }
    }
}

struct ReportsView: View {
    @ObservedObject var transactionManager: TransactionManager
    @EnvironmentObject var appState: AppState
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var filteredTransactions: [Transaction] {
        transactionManager.getTransactionsByDateRange(start: startDate, end: endDate)
    }
    
    var spendingPattern: [(index: Int, balance: Double)] {
        var pattern: [(Int, Double)] = []
        var currentBalance = 0.0
        
        for (index, transaction) in filteredTransactions.sorted(by: { $0.date < $1.date }).enumerated() {
            if transaction.type == .income {
                currentBalance += transaction.amount
            } else {
                currentBalance -= transaction.amount
            }
            pattern.append((index, currentBalance))
        }
        
        return pattern
    }
    
    var categoryData: [(category: String, amount: Double)] {
        var categoryTotals: [TransactionCategory: Double] = [:]
        
        for transaction in filteredTransactions where transaction.type == .expense {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        return categoryTotals.map { (category: $0.key.rawValue.capitalized, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Reports")
            
            ScrollView {
                VStack(spacing: 20) {
                    // Date Range Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Date Range")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(spacing: 16) {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .accentColor(AppColors.primary)
                            
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .accentColor(AppColors.primary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Spending Pattern Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending Pattern")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        if spendingPattern.isEmpty {
                            Text("No transactions found for selected date range")
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            Chart {
                                ForEach(spendingPattern, id: \.index) { point in
                                    LineMark(
                                        x: .value("Transaction", point.index),
                                        y: .value("Balance", point.balance)
                                    )
                                    .foregroundStyle(AppColors.navyBlue)
                                    .interpolationMethod(.catmullRom)
                                }
                            }
                            .frame(height: 200)
                            .chartXAxis(.hidden)
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let amount = value.as(Double.self) {
                                            Text(String(format: "\(appState.getCurrencySymbol())%.0f", amount))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Category Breakdown Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Breakdown")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        if categoryData.isEmpty {
                            Text("No expense data available for selected date range")
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            Chart {
                                ForEach(categoryData, id: \.category) { data in
                                    SectorMark(
                                        angle: .value("Amount", data.amount),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(by: .value("Category", data.category))
                                }
                            }
                            .frame(height: 250)
                            .chartLegend(position: .bottom)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Transactions Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Transactions")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        if filteredTransactions.isEmpty {
                            Text("No transactions found for this date range")
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(filteredTransactions) { transaction in
                                TransactionRow(transaction: transaction, transactionManager: transactionManager)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchView: View {
    @ObservedObject var transactionManager: TransactionManager
    @State private var searchText = ""
    @State private var selectedCategory: TransactionCategory?
    @State private var minAmount: String = ""
    @State private var maxAmount: String = ""
    
    var filteredTransactions: [Transaction] {
        var result = transactionManager.transactions
        
        if !searchText.isEmpty {
            result = result.filter { $0.description.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if let min = Double(minAmount), min > 0 {
            result = result.filter { $0.amount >= min }
        }
        
        if let max = Double(maxAmount), max > 0 {
            result = result.filter { $0.amount <= max }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Search")
            
            ScrollView {
                VStack(spacing: 20) {
                    // Search Filters Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Filters")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(spacing: 16) {
                            TextField("Search transactions", text: $searchText)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                            Picker("Category", selection: $selectedCategory) {
                                Text("All Categories").tag(nil as TransactionCategory?)
                                ForEach(TransactionCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue.capitalized).tag(category as TransactionCategory?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Amount Range")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                HStack(spacing: 12) {
                                    TextField("Min", text: $minAmount)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text("to")
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    TextField("Max", text: $maxAmount)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Results Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Results")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        if filteredTransactions.isEmpty {
                            Text("No transactions found")
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(filteredTransactions) { transaction in
                                TransactionRow(transaction: transaction, transactionManager: transactionManager)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

