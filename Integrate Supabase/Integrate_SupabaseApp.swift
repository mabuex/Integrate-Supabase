//
//  Integrate_SupabaseApp.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

@main
struct Integrate_SupabaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(Auth())
                .preferredColorScheme(.dark)
        }
    }
}
