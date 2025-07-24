//
//  Transaction.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/19/25.
//

import Foundation

enum TransactionType: String, Codable {
    case income
    case expense
}

enum TransactionCategory: String, Codable, CaseIterable {
    case salary
    case investment
    case food
    case transportation
    case housing
    case utilities
    case entertainment
    case healthcare
    case shopping
    case other
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    var date: Date
    var amount: Double
    var type: TransactionType
    var category: TransactionCategory
    var description: String
    var notes: String?
    var isRecurring: Bool
    var recurrenceInterval: Int? // Number of days between recurrences
    var recurrenceEndDate: Date? // Optional end date for the recurring transaction
    
    init(id: UUID = UUID(), date: Date = Date(), amount: Double, type: TransactionType, category: TransactionCategory, description: String, notes: String? = nil, isRecurring: Bool = false, recurrenceInterval: Int? = nil, recurrenceEndDate: Date? = nil) {
        self.id = id
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.date = calendar.date(from: components) ?? date
        self.amount = amount
        self.type = type
        self.category = category
        self.description = description
        self.notes = notes
        self.isRecurring = isRecurring
        self.recurrenceInterval = recurrenceInterval
        self.recurrenceEndDate = recurrenceEndDate
    }
}
