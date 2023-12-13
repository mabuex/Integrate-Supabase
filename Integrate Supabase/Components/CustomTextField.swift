//
//  CustomTextField.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI

struct CustomTextField: View {
    enum TextFieldType {
        case normal, secured
    }
    
    let title: String
    @Binding var text: String
    let contentType: UITextContentType
    var textFieldType: TextFieldType = .normal
    var inputAutocapitalization: TextInputAutocapitalization = .never
    var autocorrectionDisabled = false
    
    var body: some View {
        Group {
            switch textFieldType {
            case .normal:
                TextField(title, text: $text)
            case .secured:
                SecureField(title, text: $text)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.brandSecondary.opacity(0.6))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(Color.brandSecondaryOutline.opacity(0.6))
        }
        .foregroundColor(Color.brandPrimaryText)
        .textContentType(contentType)
        .textInputAutocapitalization(inputAutocapitalization)
        .autocorrectionDisabled(autocorrectionDisabled)
    }
}

#Preview {
    CustomTextField(title: "Username", text: .constant(""), contentType: .username)
}
