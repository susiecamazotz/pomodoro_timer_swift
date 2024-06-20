import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var viewModel: AuthService
    
    var lastSevenDaysSessions: [DaySession] {
        let today = Calendar.current.startOfDay(for: Date())
        let lastWeek = (0..<7).map { i -> Date in
            return Calendar.current.date(byAdding: .day, value: -i, to: today)!
        }.reversed()
        
        var daySessions: [DaySession] = []
        for date in lastWeek {
            let daySessionsForDate = viewModel.sessionsData.filter {
                Calendar.current.isDate($0.timestamp, inSameDayAs: date)
            }
            let totalDuration = daySessionsForDate.reduce(0) { $0 + $1.duration }
            daySessions.append(DaySession(date: date, totalDuration: totalDuration))
        }
        
        return daySessions
    }
    
    var sortedSessions: [AuthService.Session] {
        viewModel.sessionsData.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Weekly Session Durations")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top, 20)
                
                Chart(lastSevenDaysSessions) { daySession in
                    BarMark(
                        x: .value("Date", daySession.date, unit: .day),
                        y: .value("Total Duration", daySession.totalDuration)
                    )
                    .foregroundStyle(Color(.greenButton)) // Using custom color from assets
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                            .foregroundStyle(Color(.lightGreenButton)) // Customizing the color
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading) {
                        AxisTick()
                        AxisValueLabel()
                            .foregroundStyle(Color(.lightGreenButton)) // Customizing the color
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.background)) // Using custom background color
                        .shadow(radius: 10)
                )
                .padding(.horizontal, 10)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchSessions()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(.bottom, 32)
    }
}

struct DaySession: Identifiable {
    let id = UUID()
    let date: Date
    let totalDuration: Int
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(AuthService())
    }
}
