//
//  MessageBox.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

struct MessageBox: View {
    let type: MessageBoxType
    let content: String
    var icon: String?
    
    var onClose: () -> Void
    
    init(_ content: String, icon: String? = nil, type: MessageBoxType = .error, onClose: @escaping () -> Void) {
        self.content = content
        self.icon = icon
        self.type = type
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(type.rawValue)
                    .font(.headline)
                    .textCase(.uppercase)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "x.circle.fill")
                        .frame(width: 24, height: 24)
                    
                }
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(content)
                    .font(.caption)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(type.color.opacity(0.2))
        .background(.thinMaterial)
        .foregroundColor(type.color)
        .cornerRadius(8)
        .padding()
    }
    
    enum MessageBoxType: String {
        case error = "Error", warning = "Warning", notification = "Notification", information = "Information"
        
        var color: Color {
            switch self {
            case .error:
                Color(.systemRed)
            case .warning:
                Color(.systemOrange)
            case .notification:
                Color(.systemYellow)
            case .information:
                Color(.systemTeal)
            }
        }
    }
}

#Preview {
    MessageBox("There was an error") { }
}
