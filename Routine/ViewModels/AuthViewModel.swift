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
        if let firebaseUser = authService.getCurrentUser() {
            // Load user from Firestore
            Task {
                do {
                    let user = try await firestoreService.getUser(userId: firebaseUser.uid)
                    self.user = user
                    self.isAuthenticated = true
                } catch {
                    // If user doesn't exist in Firestore, create a basic user object
                    self.user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        displayName: firebaseUser.displayName,
                        createdAt: Date()
                    )
                    self.isAuthenticated = true
                }
            }
        } else {
            self.isAuthenticated = false
        }
    }
    
    func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        let user = try await authService.signInWithApple(credential: appleIDCredential)
                        self.user = user
                        self.isAuthenticated = true
                        self.isLoading = false
                        
                        // Save user to Firestore
                        try await firestoreService.updateUser(user)
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
