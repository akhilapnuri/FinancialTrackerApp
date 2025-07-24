//
//  CurrencyPickerView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/24/25.
//

import Foundation
import SwiftUI

struct CurrencyPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(appState.availableCurrencies.keys.sorted()), id: \.self) { currency in
                    Button(action: {
                        appState.selectedCurrency = currency
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("\(currency) (\(appState.availableCurrencies[currency] ?? ""))")
                            Spacer()
                            if currency == appState.selectedCurrency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
        }
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
    }
}
