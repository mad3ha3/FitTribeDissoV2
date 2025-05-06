//
//  InputView.swift
//  disso
//
//  Created by Madeha Ahmed on 06/04/2025.
//

import SwiftUI

//this is a reusable input view component for the following text and secure text fields
struct InputView: View {
    @Binding var text: String
    let title: String  //label displayed above the input
    let placeholder: String //text that is placed inside the input
    var isSecureField = false //if the input should hide text
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title) //field title label
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                //password/secure input
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .padding(.vertical, 8)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .padding(.vertical, 8)
            }
            
            Divider()
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
    }
}
