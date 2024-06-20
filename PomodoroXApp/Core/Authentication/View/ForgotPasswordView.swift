//
//  ForgotPasswordView.swift
//  PomodoroXApp
//
//  Created by Zuzanna Słapek on 10/01/2024.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthService

    @State private var email = ""
    @State var didSendEmail = false

    var body: some View {
        VStack {
            Spacer()
            
            Image("icons")
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .padding(.vertical, 62)
            
            VStack(spacing: 24) {
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "name@example.com")
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            }
            .padding(.horizontal)
            
            Button {
                Task { try await viewModel.sendPasswordResetEmail(toEmail: email) }
            } label: {
                HStack {
                    Text("Reset Password")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.greenButton))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1 : 0.7)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
                        
            Button {
                dismiss()
            } label: {
                Text("Return to login")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.greenButton))
            }
            .padding(.vertical, 16)
        }
        .alert(isPresented: $didSendEmail) {
            Alert(
                title: Text("Email sent"),
                message: Text("An email has been sent to \(email) to reset your password"),
                dismissButton: .default(Text("Ok"), action: {
                    dismiss()
                })
            )
        }
    }
}

// MARK: - Form Validation

extension ForgotPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
