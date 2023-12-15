//
//  SignInUpView.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

struct SignInUpView: View {
    @Environment(Auth.self) var auth: Auth
    @Environment(\.dismiss) private var dismiss
    
    var loginOption: LoginOption = .signIn
    
    @State private var result: Result<Void, Error>?
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let result {
                    if case .failure(let failure) = result {
                        MessageBox(failure.localizedDescription) {
                            withAnimation {
                                self.result = nil
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    if case .signUp = loginOption {
                        CustomTextField(
                            title: "Username",
                            text: $username,
                            contentType: .username,
                            textFieldType: .normal,
                            inputAutocapitalization: .never,
                            autocorrectionDisabled: true)
                    }
                    
                    CustomTextField(
                        title: "Email",
                        text: $email,
                        contentType: .emailAddress,
                        textFieldType: .normal,
                        inputAutocapitalization: .never,
                        autocorrectionDisabled: true)
                    
                    CustomTextField(
                        title: "Password",
                        text: $password,
                        contentType: .password,
                        textFieldType: .secured,
                        inputAutocapitalization: .never,
                        autocorrectionDisabled: true)
                    
                    Spacer()
                    
                    CustomButton(title: loginOption.lable) {
                        switch loginOption {
                        case .signIn:
                            signIn()
                        case .signUp:
                            signUp()
                        }
                    }
                    
                    Spacer()
                    
                    switch loginOption {
                    case .signIn:
                        NavigationLink("Don't have an account Sign Up") {
                            SignInUpView(loginOption: .signUp)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color.brandSecondaryText)
                    case .signUp:
                        Button("Already have an account Sign In") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color.brandSecondaryText)
                    }
                }
                .padding()
            }
            .background(Color.brandBackground)
            .navigationTitle(loginOption.lable)
        }
        .accentColor(Color.brandPrimaryText)
    }
}

#Preview {
    SignInUpView()
        .environment(Auth())
}

extension SignInUpView {
    enum LoginOption {
        case signIn, signUp
        
        var lable: String {
            switch self {
            case .signIn:
                "Sign In"
            case .signUp:
                "Sign Up"
            }
        }
    }
    
    func reset() {
        username = ""
        email = ""
        password = ""
    }
    
    func signIn() {
        Task {
            do {
                try await auth.signInWithEmail(email: email, password: password)
            } catch {
                withAnimation {
                    result = .failure(error)
                    self.reset()
                }
            }
        }
    }
    
    func signUp() {
        Task {
            do {
                try await auth.signUpWithEmail(email: email, password: password, username: username)
            } catch {
                withAnimation {
                    result = .failure(error)
                    self.reset()
                }
            }
        }
    }
}
