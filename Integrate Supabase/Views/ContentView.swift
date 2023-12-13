//
//  ContentView.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

struct ContentView: View {
    @Environment(Auth.self) private var auth: Auth
    
    @State private var selection: AppView? = .messages
    
    var body: some View {
        if auth.isLoading {
            ProgressView()
        } else if auth.session == nil {
            SignInUpView()
        } else {
            AppTabView(selection: $selection)
                .accentColor(Color.brandPrimary)
        }
    }
}

#Preview {
    ContentView()
        .environment(Auth())
}


