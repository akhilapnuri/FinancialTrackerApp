import Foundation

class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    private let userDefaultsKey = "registeredUsers"
    
    init() {
        loadUsers()
    }
    
    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let users = try? JSONDecoder().decode([User].self, from: data) {
            self.registeredUsers = users
        }
    }
    
    private func saveUsers() {
        if let data = try? JSONEncoder().encode(registeredUsers) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private var registeredUsers: [User] = []
    
    func signUp(name: String, email: String, password: String) -> Bool {
        // Check if email already exists
        guard !registeredUsers.contains(where: { $0.email == email }) else {
            return false
        }
        
        // Create new user
        let newUser = User(email: email, password: password, name: name)
        registeredUsers.append(newUser)
        saveUsers()
        
        // Save user data to UserDefaults
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        return true
    }
    
    func signIn(email: String, password: String) -> Bool {
        if let user = registeredUsers.first(where: { $0.email == email && $0.password == password }) {
            currentUser = user
            
            // Save user data to UserDefaults
            UserDefaults.standard.set(user.name, forKey: "userName")
            UserDefaults.standard.set(user.email, forKey: "userEmail")
            
            // Update preferences for the current user
            if let appState = AppState.shared as? AppState {
                appState.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode_\(user.email)")
                appState.selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency_\(user.email)") ?? "USD"
            }
            
            return true
        }
        return false
    }
    
    func signOut() {
        // Save current preferences before signing out
        if let currentUser = currentUser,
           let appState = AppState.shared as? AppState {
            UserDefaults.standard.set(appState.isDarkMode, forKey: "isDarkMode_\(currentUser.email)")
            UserDefaults.standard.set(appState.selectedCurrency, forKey: "selectedCurrency_\(currentUser.email)")
        }
        
        currentUser = nil
    }
}
