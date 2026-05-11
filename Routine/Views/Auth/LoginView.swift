// LoginView.swift

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Logo and branding
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan, .green, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .mask {
                                Image(systemName: "infinity")
                                    .font(.system(size: 50, weight: .bold))
                            }
                    }

                    Text("Routine")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.black)

                    Text("Track your nutrition with AI")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Features
                VStack(spacing: 20) {
                    FeatureRow(icon: "camera.fill", text: "Scan food with AI")
                    FeatureRow(icon: "chart.bar.fill", text: "Track calories & macros")
                    FeatureRow(icon: "drop.fill", text: "Monitor water intake")
                    FeatureRow(icon: "icloud.fill", text: "Sync across devices")
                }
                .padding(.horizontal, 40)

                Spacer()

                // Sign in button
                VStack(spacing: 16) {
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            authViewModel.prepareAppleSignInRequest(request)
                        },
                        onCompletion: { result in
                            authViewModel.handleSignInWithApple(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    .disabled(authViewModel.isLoading)
                    .opacity(authViewModel.isLoading ? 0.6 : 1.0)
                    
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.black)
                    }
                    
                    // Test Login Button (for development)
                    Button(action: {
                        authViewModel.signInForTesting()
                    }) {
                        HStack {
                            Image(systemName: "person.fill.badge.plus")
                            Text("Continue as Test User")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(authViewModel.isLoading)
                    
                    Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.4, green: 0.65, blue: 0.95))
                .font(.system(size: 22))
                .frame(width: 30)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.black)

            Spacer()
        }
    }
}
