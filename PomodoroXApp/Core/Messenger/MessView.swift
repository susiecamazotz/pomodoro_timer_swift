import SwiftUI

struct MessView: View {
    @EnvironmentObject var viewModel: AuthService
    var selectedUser: AuthService.User

    var body: some View {
        VStack {
            VStack {
                TitleRow(user: selectedUser)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(viewModel.messages, id: \.id) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .onChange(of: viewModel.lastMessageId) {
                        withAnimation {
                            proxy.scrollTo(viewModel.lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
            
            MessageField(selectedUserId: selectedUser.id)
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.fetchMessages(with: selectedUser.id)
        }
    }
}
