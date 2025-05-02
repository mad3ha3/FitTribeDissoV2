//
//  ContentView.swift
//  disso
//
//  Created by Madeha Ahmed on 17/03/2025.
//

import SwiftUI

//entry view based on whether user is logged in or not
struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainTabView() //shows this when the user is logged in and the usersession is populated with data
            } else {
                LoginView() //shows this when the user is not logged in 
            }
        }
    }
}
        #Preview {
            ContentView()
        }

