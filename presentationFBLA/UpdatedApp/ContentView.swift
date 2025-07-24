//
//  ContentView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/19/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        Group {
            if appState.isLoggedIn {
                WelcomeView()
                    .environmentObject(appState)
            } else {
                SignInView()
                    .environmentObject(appState)
            }
        }
    }
}

#Preview {
    ContentView()
}
