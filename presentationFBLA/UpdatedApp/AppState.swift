//
//  AppState.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/22/25.
//

import Foundation
import SwiftUI

extension NumberFormatter {
    static func currencyFormatter(currencyCode: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter
    }
}

class AppState: ObservableObject {
    @Published var authManager = AuthenticationManager()
    @Published var transactionManager = TransactionManager()
    @Published var isLoggedIn = false
    @Published var selectedCurrency: String {
        didSet {
            if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
                UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency_\(userEmail)")
            }
        }
    }
    @Published var isDarkMode: Bool {
        didSet {
            if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
                UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode_\(userEmail)")
            }
        }
    }
    
    static let shared = AppState()
    
    private init() {
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            self.selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency_\(userEmail)") ?? "USD"
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode_\(userEmail)")
        } else {
            self.selectedCurrency = "USD"
            self.isDarkMode = false
        }
    }
    
    let availableCurrencies = [
        "USD": "$",
        "EUR": "€",
        "GBP": "£",
        "JPY": "¥",
        "INR": "₹",
        "AUD": "A$",
        "CAD": "C$",
        "CHF": "Fr",
        "CNY": "¥",
        "NZD": "NZ$"
    ]
    
    func getCurrencySymbol() -> String {
        return availableCurrencies[selectedCurrency] ?? "$"
    }
}
