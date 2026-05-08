import SwiftUI

// Uncomment when Firebase is added via SPM:
// import FirebaseCore

@main
struct RoutineApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Initialize Firebase
        // Uncomment when Firebase is added:
        // FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    ContentView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
