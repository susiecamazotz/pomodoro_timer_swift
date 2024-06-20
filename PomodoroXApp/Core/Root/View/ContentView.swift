import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthService

    var body: some View {
        Group {
            #if os(watchOS)
            WatchTimerView()
            #else
            if viewModel.userSession != nil {
                PomodoroTabView()
            } else {
                LoginView()
            }
            #endif
        }
        .onAppear {
            // Ensure the view updates when the authentication state changes
            // viewModel.signOut()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthService())
    }
}
