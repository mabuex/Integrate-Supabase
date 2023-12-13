//
//  AppTabView.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

struct AppTabView: View {
    @Binding var selection: AppView?
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppView.allCases) { view in
                view.destination
                    .tag(view as AppView?)
                    .tabItem { view.label }
            }
        }
    }
}

#Preview {
    AppTabView(selection: .constant(.messages))
}
