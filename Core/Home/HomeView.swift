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
    @State private var showAchievement = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome back to FitTribe!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // View Achievements Card
                VStack(spacing: 16) {
                    Text("View your achievement levels based on your points!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)

                    Button {
                        showAchievement = true
                    } label: {
                        HStack {
                            Text("View Your Achievements")
                            Image(systemName: "trophy.fill")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("AppOrange"))
                        )
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("AppOrange"), lineWidth: 1)
                        .background(Color(.systemBackground).cornerRadius(16))
                )
                .padding(.horizontal)

                // Log Gym Attendance Card
                VStack(spacing: 16) {
                    Text("Log your gym attendance today to gain a point")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)

                    Button {
                        showingCheckInAlert = true
                    } label: {
                        HStack {
                            Text("Gym Check In")
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(gymAttendanceViewModel.hasCheckedInToday ? Color.gray : Color("AppOrange"))
                        )
                    }
                    .disabled(gymAttendanceViewModel.hasCheckedInToday)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("AppOrange"), lineWidth: 1)
                        .background(Color(.systemBackground).cornerRadius(16))
                )
                .padding(.horizontal)

                // Search Users Card
                VStack(spacing: 16) {
                    Text("Search for other users on the app to give them a follow and start competing!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)

                    Button {
                        showSearch = true
                    } label: {
                        HStack {
                            Text("Search For Users")
                            Image(systemName: "magnifyingglass")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("AppOrange"))
                        )
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("AppOrange"), lineWidth: 1)
                        .background(Color(.systemBackground).cornerRadius(16))
                )
                .padding(.horizontal)

                // goals
                NavigationLink(destination: GoalsView(goalsViewModel: goalsViewModel)) {
                    GoalsProgressCard(goalsViewModel: goalsViewModel)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
            .sheet(isPresented: $showSearch) {
                SearchUserView()
            }
            .sheet(isPresented: $showAchievement) {
                AchievementView()
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals")
                .font(.headline)
                .foregroundColor(.primary)

            if goalsViewModel.allGoals > 0 {
                ProgressView(
                    value: Double(goalsViewModel.completedGoals),
                    total: Double(goalsViewModel.allGoals)
                )
                .accentColor(Color("AppOrange"))
                .frame(height: 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6))
                )
                .padding(.vertical, 4)

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
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("AppOrange"), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
