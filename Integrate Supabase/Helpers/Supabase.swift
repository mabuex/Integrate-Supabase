//
//  Supabase.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import Foundation
import Supabase

fileprivate enum Constants {
    static let supabaseURL = URL(string: "SUPABASE_URL")!
    static let supabaseKey = "SUPABASE_ANON_KEY"
}

class Supabase {
    let client: SupabaseClient
    
    static let shared = Supabase()
    
    init() {
        client = SupabaseClient(
            supabaseURL: Constants.supabaseURL,
            supabaseKey: Constants.supabaseKey
        )
        
//        client.realtime.logger = { print($0) }
    }
}
