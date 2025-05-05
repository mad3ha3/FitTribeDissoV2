//
//  HomeView.swift
//  disso
//
//  Created by Madeha Ahmed on 09/04/2025.
//

import SwiftUI
import FirebaseAuth

//the main home screen of the app, what user sees when they first log in
struct HomeView: View {
    @State private var showSearch = false
    @EnvironmentObject var authViewModel: AuthViewModel //access to the authentication state and current user info
    @StateObject private var gymAttendanceViewModel = GymAttendanceViewModel()
    @StateObject private var goalsViewModel = GoalsViewModel()
    @State private var showingCheckInAlert = false
    @State private var checkInSuccess = false
    @AppStorage("notificationScheduled") private var notificationScheduled = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20){
                Text("Welcome back to FitTribe!")
                    .font(.title)
                    .fontWeight(.bold)
                
                // goals
                NavigationLink(destination: GoalsView(goalsViewModel: goalsViewModel)) {
                     GoalsProgressCard(goalsViewModel: goalsViewModel)
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
                            .fill(gymAttendanceViewModel.hasCheckedInToday ? Color.gray : Color("AppOrange"))
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
                            .fill(Color("AppOrange"))
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            //.navigationTitle("Home")
            .sheet(isPresented: $showSearch) {
                SearchUserView()
            }
        }
        .onAppear {
            if !notificationScheduled {
                NotificationManager.shared.checkNotificationPermission()
                notificationScheduled = true
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

struct GoalsProgressCard: View {
    @ObservedObject var goalsViewModel: GoalsViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Goals")
                .font(.headline)
                .foregroundColor(.primary)

            if goalsViewModel.allGoals > 0 {
                ProgressView(
                    value: Double(goalsViewModel.completedGoals),
                    total: Double(goalsViewModel.allGoals)
                )
                .accentColor(Color("AppOrange"))
                Text("\(goalsViewModel.completedGoals) of \(goalsViewModel.allGoals) completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Tap to view your goals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("AppOrange"), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
