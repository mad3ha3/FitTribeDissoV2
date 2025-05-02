import SwiftUI

struct WorkoutLogView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var selectedDay: WeekDay = .monday
    @State private var selectedDate: Date = Date()
    @State private var showingAddWorkout = false
    @State private var showingCalendar = false
    
    var filteredWorkouts: [Workout] {
        viewModel.workouts.filter { workout in
            Calendar.current.isDate(workout.date, inSameDayAs: selectedDate)
        }
    }
    
    private func updateWeekdayFromDate(_ date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // Calendar returns 1 for Sunday, 2 for Monday, etc.
        let weekdays: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        selectedDay = weekdays[weekday - 1]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Weekday selector
                WeekdaySelector(selectedDay: $selectedDay)
                    .padding(.horizontal)
                    .onChange(of: selectedDay) { oldValue, newValue in
                        selectedDate = newValue.date
                    }
                
                // Calendar button
                NavigationLink(destination: CalendarView(selectedDate: $selectedDate, onDateSelected: { date in
                    selectedDate = date
                    updateWeekdayFromDate(date)
                })) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(selectedDate.formatted(date: .long, time: .omitted))
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.vertical, 8)
                }
                
                Divider()
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task {
                                await viewModel.refreshWorkouts()
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else if filteredWorkouts.isEmpty {
                    VStack {
                        Text("No workouts for \(selectedDate.formatted(date: .long, time: .omitted))")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutRow(workout: workout)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Workout Log")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(workoutViewModel: viewModel, selectedDay: selectedDay)
            }
        }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDateSelected(selectedDate)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WorkoutLogView()
        .environmentObject(AuthViewModel())
}
