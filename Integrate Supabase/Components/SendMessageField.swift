//
//  SendMessageField.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/13.
//

import SwiftUI

struct SendMessageField: View {
    @State private var textViewValue = String()
    @State private var textViewHeight: CGFloat = 50.0
    
    @Binding var text: String
    
    @FocusState private var focusedField: Bool
    
    var onSent: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                TextField("Type a message...", text: $text, axis: .vertical)
                    .focused($focusedField)
                    .lineLimit(5)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.brandSecondary.opacity(0.6))
                    .cornerRadius(20)
                
                Button(action: onSent) {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(Angle(degrees: 45))
                        .foregroundColor(Color.brandPrimary)
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    SendMessageField(text: .constant("Hello!")) {
        
    }
}
