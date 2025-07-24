//
//  WelcomeView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/19/25.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingMainMenu = false
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.9, green: 0.95, blue: 1.0) // Light blue background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 40)
                    
                    Text("\(userName), welcome to FinWin!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5)) // Dark blue
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("What the future of finance includes:")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5)) // Dark blue
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 25) {
                        FeatureRow(icon: "💰", text: "Transaction Management")
                        FeatureRow(icon: "📊", text: "Financial Overview")
                        FeatureRow(icon: "📈", text: "Reporting Tools")
                        FeatureRow(icon: "🔍", text: "Search & Filter")
                        FeatureRow(icon: "ℹ️", text: "More Information")
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Button(action: {
                        showingMainMenu = true
                    }) {
                        Text("Continue to Dashboard")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingMainMenu) {
                MainMenuView(isLoggedIn: $appState.isLoggedIn)
                    .environmentObject(appState)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 20) {
            Text(icon)
                .font(.system(size: 32))
            Text(text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5)) // Dark blue
        }
    }
}
 
