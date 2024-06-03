import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var viewModel: AuthService
    
    var body: some View {
        NavigationView {
            List(viewModel.allSessionsData) { userSession in
                HStack {
                    Text(userSession.fullname)
                        .font(.headline)
                        .foregroundColor(Color(.greenButton)) // Using custom color
                    Spacer()
                    Text("\(userSession.totalDuration) seconds")
                        .font(.subheadline)
                        .foregroundColor(Color(.lightGreenButton)) // Using custom color
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.background)) // Using custom background color
                        .shadow(radius: 5)
                )
                .padding(.horizontal)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Friends")
            .onAppear {
                Task {
                    await viewModel.fetchAllSessions()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
            .environmentObject(AuthService())
    }
}
