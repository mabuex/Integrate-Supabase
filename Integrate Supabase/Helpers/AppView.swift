//
//  AppView.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

enum AppView: Codable, Hashable, Identifiable, CaseIterable {
    case messages
    case profile
    
    var id: AppView { self }
}

extension AppView {
    @ViewBuilder
    var label: some View {
        switch self {
        case .messages:
            Label("Messages", systemImage: "bubble")
        case .profile:
            Label("Profile", systemImage: "person")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .messages:
            MessagesView()
        case .profile:
            ProfileView()
        }
    }
}
