//
//  PlaceholderAvatar.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/13.
//

import SwiftUI

struct PlaceholderAvatar: View {
    var size: CGFloat = 80
    
    var body: some View {
        Circle()
            .fill(Color(.lightGray))
            .overlay {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: size / 1.5, height: size / 1.5)
            }
            .frame(width: size, height: size)
    }
}

#Preview {
    PlaceholderAvatar()
}
