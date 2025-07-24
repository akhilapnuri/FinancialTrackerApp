import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    @StateObject private var appStateObject = AppState.shared
    @State private var showingCurrencyPicker = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Personal Information")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(userName)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Email")
                    Spacer()
                    Text(userEmail)
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Preferences")) {
                Picker("Currency", selection: $appState.selectedCurrency) {
                    ForEach(Array(appState.availableCurrencies.keys.sorted()), id: \.self) { currency in
                        Text("\(currency) (\(appState.availableCurrencies[currency] ?? ""))")
                            .tag(currency)
                    }
                }
                
                Toggle("Dark Mode", isOn: $appState.isDarkMode)
            }
            
            Section(header: Text("Account")) {
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarItems(trailing: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
        })
        .sheet(isPresented: $showingCurrencyPicker) {
            CurrencyPickerView()
        }
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    appState.authManager.signOut()
                    appState.isLoggedIn = false
                },
                secondaryButton: .cancel()
            )
        }
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
    }
}
