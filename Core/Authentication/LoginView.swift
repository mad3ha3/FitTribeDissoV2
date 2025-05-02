//
//  LoginView.swift
//  disso
//
//  Created by Madeha Ahmed on 06/04/2025.
//

import SwiftUI


//View for user login, email and password fields w validation
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        NavigationStack {
            VStack {
                //image, app logo
                Image("AppIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 250)
                    .padding(.vertical, 32)
                
                //form fields
                VStack(spacing: 25) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none) //avoids capitalising email field accidentally
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter Password",
                              isSecureField: true)//preset this field as false
                
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //sign in button
                
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("Sign In")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemOrange))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(20)
                .padding(.top, 20)
            
                
                Spacer()
                


                //navigation to sign up 
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size:20))
                }
                
            }
        }
    }
}

//MARK: - AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol{
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
    
    
}

#Preview {
    LoginView()
}
