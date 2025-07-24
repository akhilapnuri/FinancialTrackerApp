//
//  SignInView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/19/25.
//

import Foundation
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.9, green: 0.95, blue: 1.0) // Light blue background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 60)
                    
                    Text("FinWin: The app that can make your finances win.")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5)) // Dark blue
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 60)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        if appState.authManager.signIn(email: email, password: password) {
                            appState.isLoggedIn = true
                        } else {
                            alertMessage = "Invalid email or password"
                            showingAlert = true
                        }
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Button(action: {
                        showingSignUp = true
                    }) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
                    .environmentObject(appState)
            }
        }
    }
}

