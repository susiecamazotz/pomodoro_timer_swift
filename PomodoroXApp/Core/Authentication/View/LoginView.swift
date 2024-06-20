import SwiftUI

struct LoginView: View {
    @State internal var email = ""
    @State internal var password = ""
    @EnvironmentObject var viewModel: AuthService
    
    var body: some View {
        NavigationStack {
            VStack {
                // Top decoration with circle shapes and "Log In" text
                ZStack {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color(.greenButton))
                                .frame(width: 300, height: 300)
                                .offset(x: -90, y: -80)
                                .opacity(0.8)
                            
                        }
                        .frame(height: 200)
                        .padding(.top, 30)
                        
                        Spacer()
                    }
                    
                    Text("Log In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 80)
                        .offset(x: -90, y: -80)
                }
                .frame(height: 250)
                
                Spacer()
                
                VStack(spacing: 34) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    .accessibility(identifier: "emailTextField")
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                    .accessibility(identifier: "passwordSecureField")
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                NavigationLink {
                    ForgotPasswordView()
                } label: {
                    Text("Forgot Password?")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(Color(.greenButton))
                        .padding(.trailing, 32)
                }
                .accessibility(identifier: "forgotPasswordLink")
                
                Button {
                    Task { try await viewModel.singIn(withEmail: email, password: password) }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 64, height: 48)
                    .background(Color(.greenButton))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.7)
                .padding(.top, 24)
                .accessibility(identifier: "signInButton")
                
                Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Text("Sign up")
                            .fontWeight(.bold)
                            .foregroundColor(Color(.greenButton))
                    }
                    .font(.system(size: 14))
                }
                .padding(.bottom, 32)
                .accessibility(identifier: "signUpLink")
                
                Spacer()
            }
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthService())
    }
}
