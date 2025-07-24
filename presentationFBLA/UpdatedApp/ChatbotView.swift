//
//  ChatbotView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/24/25.
//

import Foundation
import SwiftUI

struct ChatbotView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText = ""
    @State private var messages: [Message] = []
    
    let predefinedQuestions = [
        "How do I build credit as a student?",
        "What is the best budgeting method?",
        "How much did my prom dress in category shopping cost?",
        "When will my next payment for deep research subscription occur?"
    ]
    
    let responses = [
        "How do I build credit as a student?": "Start with:\n\n• A secured credit card (try Discover IT)\n• Pay utilities on time\n• Keep usage under 30% of limit",
        "What is the best budgeting method?": "The 50/30/20 Rule:\n\n• 50% needs (rent, groceries)\n• 30% wants (dining out, hobbies)\n• 20% savings/debt",
        "How much did my prom dress in category shopping cost?": "Your prom dress cost you $500.",
        "When will my next payment for deep research subscription occur?": "Your next payment for deep research subscription happens on May 30th, a total of $200."
    ]
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("FinWin Assistant")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Chat messages
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Suggested questions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(predefinedQuestions, id: \.self) { question in
                        Button(action: {
                            sendMessage(question)
                        }) {
                            Text(question)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            
            // Input field
            HStack {
                TextField("Type your question...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    sendMessage(messageText)
                    messageText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .background(Color(red: 0.9, green: 0.95, blue: 1.0))
    }
    
    private func sendMessage(_ text: String) {
        let userMessage = Message(text: text, isUser: true)
        messages.append(userMessage)
        
        // Simulate bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let response = responses[text] {
                let botMessage = Message(text: response, isUser: false)
                messages.append(botMessage)
            } else {
                let botMessage = Message(text: "I'm sorry, I don't have an answer for that yet. Please try one of the suggested questions.", isUser: false)
                messages.append(botMessage)
            }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(20)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}
