//
//  CustomButton.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

struct CustomButton: View {
    enum ButtonStyle {
        case primary, secondary
    }
    
    let title: String
    var height: CGFloat = 42
    var font: Font = .body
    var fontWeight: Font.Weight = .semibold
    var style: ButtonStyle = .primary
    
    var onAction: () -> Void
    
    var body: some View {
        Button(action: onAction) {
            Text(title)
                .font(font)
                .fontWeight(fontWeight)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.brandPrimaryText)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(mainColor)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(outlineColor)
                }
        }
    }
    
    var mainColor: Color {
        style == .primary ? Color.brandPrimary : Color.brandSecondary
    }
    
    var outlineColor: Color {
        style == .primary ? Color.brandPrimaryOutline : Color.brandSecondaryOutline
    }
}

#Preview {
    CustomButton(title: "Sign In") { }
}
