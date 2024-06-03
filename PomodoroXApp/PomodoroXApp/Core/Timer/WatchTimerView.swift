import SwiftUI

struct WatchTimerView: View {
    @State internal var mainTimeRemaining: Int = 5
    @State internal var mainTime: Int = 5
    @State internal var timerActive = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.green)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(Double(mainTimeRemaining) / Double(mainTime), 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.green)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: mainTimeRemaining)
                
                Text(timeString(from: mainTimeRemaining))
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.green)
            }
            .frame(width: 100, height: 100)
            
            HStack(spacing: 20) {
                Button(action: {
                    self.stopTimers()
                }) {
                    Text("Cancel")
                        .font(.title2)
                        .padding()
                        .frame(width: 100)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .opacity(timerActive ? 1.0 : 0.0)
                
                Button(action: {
                    self.startTimers()
                }) {
                    Text("Start")
                        .font(.title2)
                        .padding()
                        .frame(width: 100)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
        // Implement any completion logic if needed
    }
}

struct WatchTimerView_Previews: PreviewProvider {
    static var previews: some View {
        WatchTimerView()
    }
}
