//
//  CurrencyConverterView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/24/25.
//

import Foundation
import SwiftUI

struct CurrencyConverterView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputAmount: String = ""
    @State private var fromCurrency: String = "USD"
    @State private var toCurrency: String = "INR"
    @State private var convertedAmount: Double = 0.0
    
    // Currency data with symbols
    private let currencies: [(code: String, symbol: String)] = [
        ("AUD", "A$"),
        ("CAD", "C$"),
        ("CHF", "Fr"),
        ("CNY", "¥"),
        ("EUR", "€"),
        ("GBP", "£"),
        ("INR", "₹"),
        ("JPY", "¥"),
        ("NZD", "NZ$"),
        ("USD", "$")
    ]
    
    // Sample exchange rates (in a real app, these would come from an API)
    private let exchangeRates: [String: [String: Double]] = [
        "USD": ["AUD": 1.52, "CAD": 1.37, "CHF": 0.91, "CNY": 7.24, "EUR": 0.92, "GBP": 0.79, "INR": 83.0, "JPY": 155.0, "NZD": 1.68],
        "AUD": ["USD": 0.66, "CAD": 0.90, "CHF": 0.60, "CNY": 4.76, "EUR": 0.61, "GBP": 0.52, "INR": 54.6, "JPY": 102.0, "NZD": 1.10],
        "CAD": ["USD": 0.73, "AUD": 1.11, "CHF": 0.66, "CNY": 5.28, "EUR": 0.67, "GBP": 0.58, "INR": 60.6, "JPY": 113.0, "NZD": 1.22],
        "CHF": ["USD": 1.10, "AUD": 1.67, "CAD": 1.51, "CNY": 7.95, "EUR": 1.01, "GBP": 0.87, "INR": 91.3, "JPY": 170.0, "NZD": 1.84],
        "CNY": ["USD": 0.14, "AUD": 0.21, "CAD": 0.19, "CHF": 0.13, "EUR": 0.13, "GBP": 0.11, "INR": 11.5, "JPY": 21.4, "NZD": 0.23],
        "EUR": ["USD": 1.09, "AUD": 1.64, "CAD": 1.49, "CHF": 0.99, "CNY": 7.87, "GBP": 0.86, "INR": 90.2, "JPY": 168.0, "NZD": 1.82],
        "GBP": ["USD": 1.27, "AUD": 1.92, "CAD": 1.74, "CHF": 1.15, "CNY": 9.15, "EUR": 1.16, "INR": 105.0, "JPY": 196.0, "NZD": 2.12],
        "INR": ["USD": 0.012, "AUD": 0.018, "CAD": 0.016, "CHF": 0.011, "CNY": 0.087, "EUR": 0.011, "GBP": 0.0095, "JPY": 1.87, "NZD": 0.020],
        "JPY": ["USD": 0.0064, "AUD": 0.0098, "CAD": 0.0089, "CHF": 0.0059, "CNY": 0.047, "EUR": 0.0060, "GBP": 0.0051, "INR": 0.53, "NZD": 0.011],
        "NZD": ["USD": 0.60, "AUD": 0.91, "CAD": 0.82, "CHF": 0.54, "CNY": 4.31, "EUR": 0.55, "GBP": 0.47, "INR": 49.4, "JPY": 92.2]
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Currency Converter")
                .font(.headline)
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: 16) {
                // Input amount
                TextField("Amount", text: $inputAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: inputAmount) { _ in
                        convertCurrency()
                    }
                
                // Currency selection
                HStack(spacing: 20) {
                    Picker("From", selection: $fromCurrency) {
                        ForEach(currencies, id: \.code) { currency in
                            Text("\(currency.code) (\(currency.symbol))").tag(currency.code)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(AppColors.primary)
                    
                    Picker("To", selection: $toCurrency) {
                        ForEach(currencies, id: \.code) { currency in
                            Text("\(currency.code) (\(currency.symbol))").tag(currency.code)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .onChange(of: fromCurrency) { _ in convertCurrency() }
                .onChange(of: toCurrency) { _ in convertCurrency() }
                
                // Converted amount
                if let amount = Double(inputAmount), amount > 0 {
                    if let toSymbol = currencies.first(where: { $0.code == toCurrency })?.symbol {
                        Text("\(toSymbol)\(String(format: "%.2f", convertedAmount))")
                            .font(.title2)
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func convertCurrency() {
        guard let amount = Double(inputAmount), amount > 0 else {
            convertedAmount = 0
            return
        }
        
        if fromCurrency == toCurrency {
            convertedAmount = amount
            return
        }
        
        if let rate = exchangeRates[fromCurrency]?[toCurrency] {
            convertedAmount = amount * rate
        } else if let inverseRate = exchangeRates[toCurrency]?[fromCurrency] {
            convertedAmount = amount / inverseRate
        }
    }
}
