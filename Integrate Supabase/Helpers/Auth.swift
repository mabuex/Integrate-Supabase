//
//  Auth.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import Foundation
import Supabase
import Observation

@Observable
final class Auth {
    private let client = Supabase.shared.client
    
    var session: Session? {
        didSet {
            Task {
                await fetchProfile()
            }
        }
    }
    var profile: Profile?
    var isLoading = false
    
    init() {
        Task {
            try await getCurrentSession()
        }
    }
    
    func fetchProfile() async {
        guard let userID = session?.user.id else { return }
        self.profile = await Profile.instance(with: userID)
    }
    
    func getCurrentSession() async throws {
        isLoading = true
        
        defer { isLoading = false }
        
        let session = try await client.auth.session
        self.session = session
        isLoading = false
    }
    
    func sessionStatus() async {
        for await (event, session) in await client.auth.authStateChanges {
            guard event == .signedIn || event == .signedOut else {
                return
            }
            
            self.session = session
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        
        self.session = session
    }
    
    func signUpWithEmail(email: String, password: String, username: String) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["username": AnyJSON.string(username)]
        )
        
        self.session = response.session
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        self.session = nil
    }
}
