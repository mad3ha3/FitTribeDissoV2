//
//  RegistrationView.swift
//  disso
//
//  Created by Madeha Ahmed on 07/04/2025.
//

import SwiftUI

//view for account registration
struct RegistrationView: View {
    @State private var email: String = ""
    @State private var fullname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            
            //image, app logo
            Image("AppIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 250)
                .padding(.vertical, 6)
            
            //form fields
            VStack(spacing: 25) {
                
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "name@eample.com")
                .autocapitalization(.none) //avoids capitalising email field accidentally
                
                InputView(text: $fullname,
                          title: "Full Name",
                          placeholder: "Your Name")
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter Password",
                          isSecureField: true)//preset this field as false
                .autocapitalization(.none)
                
                //confirm password with validation icon set
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Re-enter Password",
                              isSecureField: true)
                    .autocapitalization(.none)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            
            //button for sign up
            Button {
                Task {
                    try await viewModel.createUser(withEmail: email,
                                                   password: password,
                                                   fullname: fullname)
                }
            } label: {
                HStack {
                    Text("Sign Up")
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
            
            //already have an account button
            Button {
                dismiss()
            } label: {
                HStack {
                    Text("Already Have An Account?")
                    Text("Sign In")
                        .fontWeight(.bold)
                }
                .font(.system(size:16))
            }
        }
    }
}
//MARK: - AuthenticationFormProtocol

extension RegistrationView: AuthenticationFormProtocol{
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
        
    }
}
    #Preview {
        RegistrationView()
    }

