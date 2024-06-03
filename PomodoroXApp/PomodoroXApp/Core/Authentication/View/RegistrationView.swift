//
//  RegistrationView.swift
//  PomodoroXApp
//
//  Created by Zuzanna Słapek on 09/01/2024.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthService
    
    @State internal var email = ""
    @State internal var password = ""
    @State internal var fullname = ""
    @State internal var username = ""
    
    var body: some View {
        VStack {
            Image("icons")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .padding(.vertical, 62)
            
            VStack(spacing: 34) {
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "name@example.com")
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                InputView(text: $username,
                          title: "Username",
                          placeholder: "username")
                .autocapitalization(.none)
                InputView(text: $fullname,
                          title: "Full Name",
                          placeholder: "Your Name")
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
            Button {
                Task { try await viewModel.createUser(withEmail: email,
                                                      password: password,
                                                      fullname: fullname,
                                                      username: username) }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
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
                HStack (spacing: 3){
                    Text("Already have an account?")
                        .foregroundColor(Color.black)
                    Text("Sign in")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(Color(.greenButton))
                }
                .font(.system(size: 14))
            }
        }
    }
}

// MARK: - Form Validation

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && !fullname.isEmpty
        && !username.isEmpty
        && password.count > 5
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
