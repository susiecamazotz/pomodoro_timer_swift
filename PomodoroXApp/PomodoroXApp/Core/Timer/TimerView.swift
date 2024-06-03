import SwiftUI

struct TimerView: View {
    @EnvironmentObject var viewModel: AuthService
    
    @State internal var mainTimeRemaining: Int = 5
    @State internal var mainTime: Int = 5
    
    @State internal var timerActive = false
    
    init() {
        _mainTimeRemaining = State(initialValue: 5)
        _mainTime = State(initialValue: 5)
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(Color.lightGreen)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(Double(mainTimeRemaining) / Double(mainTime), 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.lightGreen)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: mainTimeRemaining)
                
                Text(timeString(from: mainTimeRemaining))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.lightGreen)
            }
            .frame(width: 300, height: 300)
            
            ZStack {
                Button(action: {
                    self.stopTimers()
                }) {
                    Text("Cancel")
                        .font(.title2)
                        .padding()
                        .frame(width: 120)
                        .background(Color.lightGreenButton)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .opacity(timerActive ? 1.0 : 0.0)
                
                Button(action: {
                    self.startTimers()
                }) {
                    Text("Start")
                        .font(.title2)
                        .padding()
                        .frame(width: 120)
                        .background(Color.greenButton)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .opacity(timerActive ? 0.0 : 1.0)
            }
            .animation(.easeInOut, value: timerActive)
        }
        .onReceive(timer) { _ in
            guard self.timerActive else { return }
            
            if self.mainTimeRemaining > 0 {
                self.mainTimeRemaining -= 1
            } else {
                self.timerCompleted()
                self.resetTimers() // Reset the timer
            }
        }
        .onDisappear() {
            self.timer.upstream.connect().cancel()
        }
    }
    
    func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimers() {
        self.resetTimers()
        self.timerActive = true
    }
    
    func stopTimers() {
        self.timerActive = false
    }
    
    func resetTimers() {
        self.timerActive = false
        self.mainTimeRemaining = mainTime
    }
    
    func timerCompleted() {
        if let userId = viewModel.userSession?.uid {
            Task {
                do {
                    try await viewModel.saveWorkSession(duration: mainTime, userId: userId)
                } catch {
                    print("Error saving work session: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(AuthService()) // Only if your TimerView needs the AuthService
    }
}
