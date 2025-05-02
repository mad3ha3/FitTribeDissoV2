//
//  HomeView.swift
//  disso
//
//  Created by Madeha Ahmed on 09/04/2025.
//

import SwiftUI

//the main home screen of the app, what user sees when they first log in
struct HomeView: View {
    @State private var showSearch = false
    @EnvironmentObject var authViewModel: AuthViewModel //access tp the authentication state and current user info
    @StateObject private var gymAttendanceViewModel = GymAttendanceViewModel()
    @State private var showingCheckInAlert = false
    @State private var checkInSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20){
                Text("Welcome back to FitTribe!")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    VStack{
                        Image(systemName: "flame.fill")
                            .font(.largeTitle)
                            .foregroundColor(.yellow)
                        Text("Badge: Bronze")
                    }
                }
                
                //monthly goals
                NavigationLink(destination: GoalsView()) {
                    VStack(alignment: .leading, spacing: 8){
                        Text("Your Goals")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Tap to view or add your goals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding(.horizontal)
                
                //log gym attendance button
                Button {
                    showingCheckInAlert = true
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Check In")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(gymAttendanceViewModel.hasCheckedInToday ? Color.gray : Color.blue)
                    )
                }
                .disabled(gymAttendanceViewModel.hasCheckedInToday)
                .padding()
                
                //search users button
                Button {
                    showSearch = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search Users")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .sheet(isPresented: $showSearch) {
                SearchUserView()
            }
        }
        .alert("Check In", isPresented: $showingCheckInAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                Task {
                    checkInSuccess = await gymAttendanceViewModel.checkIn()
                }
            }
        } message: {
            Text("Are you sure you want to check in?")
        }
        .alert("Success", isPresented: $checkInSuccess) {
            Button("OK") { }
        } message: {
            Text("You have successfully checked in!")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
