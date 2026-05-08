// AuthViewModel.swift

import Foundation
import AuthenticationServices

@MainActor
class AuthViewModel: NSObject, ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService()
    private let firestoreService = FirestoreService()
    
    override init() {
        super.init()
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // TODO: Implement with Firebase Auth
        // For now, simulate authenticated state for development
        #if DEBUG
        // Mock user for development
        self.user = User(
            id: "mock-user-id",
            email: "test@example.com",
            displayName: "Test User",
            createdAt: Date()
        )
        self.isAuthenticated = true
        #else
        if authService.getCurrentUser() != nil {
            // Load user from Firestore
            Task {
                do {
                    // let user = try await firestoreService.getUser(userId: firebaseUser.uid)
                    // self.user = user
                    // self.isAuthenticated = true
                } catch {
                    self.isAuthenticated = false
                }
            }
        }
        #endif
    }
    
    func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        // TODO: Implement Sign in with Apple
        isLoading = true
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        // let user = try await authService.signInWithApple(credential: appleIDCredential)
                        // self.user = user
                        // self.isAuthenticated = true
                        self.isLoading = false
                    } catch {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
