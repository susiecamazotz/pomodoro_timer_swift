//
//  InputView.swift
//  PomodoroXApp
//
//  Created by Zuzanna Słapek on 09/01/2024.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .disableAutocorrection(true)
                
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
        }
        .padding(.bottom, 8)
        .background(
            VStack {
                Spacer()
                Divider()
            }
        )
    }
}

struct InputView_Prewievs: PreviewProvider {
    static var previews: some View {
        InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
    }
}

