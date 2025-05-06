import SwiftUI

//shows the tabs on the app
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            WorkoutTypeView(viewModel: WorkoutViewModel())
                .tabItem {
                    Label("Workout", systemImage: "figure.run")
                }
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }
            
            InboxView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
            
            ProfileView(user: nil)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 
