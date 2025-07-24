//
//  MoreInfoView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/24/25.
//

import Foundation
import SwiftUI

struct MoreInfoView: View {
    @State private var showingChatbot = false
    @State private var expandedQuestions: Set<Int> = []
    
    let faqItems = [
        (question: "How do I add a transaction?",
         answer: "To add a transaction, go to the Transactions tab and tap the + button in the top-right corner. Fill in the transaction details and tap Save."),
        (question: "How do I generate a report?",
         answer: "Go to the Reports tab, select your desired date range, and the app will automatically generate a report of your transactions for that period."),
        (question: "How do I search for specific transactions?",
         answer: "Use the Search tab to find transactions. You can search by description or filter by category using the dropdown menu."),
        (question: "How do I view my financial overview?",
         answer: "The Overview tab shows your current balance, income vs expenses, and spending patterns in an easy-to-read format."),
        (question: "How do I edit or delete a transaction?",
         answer: "In the Transactions tab, swipe left on any transaction to reveal edit and delete options. Tap the appropriate button to make changes.")
    ]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HeaderView(title: "More Information")
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Currency Converter Card
                        CurrencyConverterView()
                            .padding(.horizontal)
                        
                        // FAQ Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Frequently Asked Questions")
                                .font(.headline)
                                .foregroundColor(AppColors.textSecondary)
                            
                            VStack(spacing: 16) {
                                ForEach(Array(faqItems.enumerated()), id: \.offset) { index, item in
                                    DisclosureGroup(
                                        isExpanded: Binding(
                                            get: { expandedQuestions.contains(index) },
                                            set: { isExpanded in
                                                if isExpanded {
                                                    expandedQuestions.insert(index)
                                                } else {
                                                    expandedQuestions.remove(index)
                                                }
                                            }
                                        )
                                    ) {
                                        Text(item.answer)
                                            .foregroundColor(AppColors.textSecondary)
                                            .padding(.vertical, 8)
                                    } label: {
                                        Text(item.question)
                                            .font(.headline)
                                            .foregroundColor(AppColors.textPrimary)
                                    }
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
            
            // Chat button
            Button(action: {
                showingChatbot = true
            }) {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary)
                    .padding()
                    .background(AppColors.cardBackground)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingChatbot) {
            ChatbotView()
        }
    }
}
