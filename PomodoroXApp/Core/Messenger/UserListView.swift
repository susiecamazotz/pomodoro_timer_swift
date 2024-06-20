import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: AuthService
    var selectedUser: AuthService.User
    
    var body: some View {
        VStack(spacing: 0) {
            TitleRow(user: selectedUser)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color(.myWhite))
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(viewModel.messages, id: \.id) { message in
                        MessageBubble(message: message)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                .background(Color(.myWhite))
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .onChange(of: viewModel.lastMessageId) {
                    withAnimation {
                        proxy.scrollTo(viewModel.lastMessageId, anchor: .bottom)
                    }
                }
            }
            
            MessageField { messageText in
                viewModel.sendMessage(text: messageText, to: selectedUser.id)
            }
            .background(Color(.myWhite))
            .cornerRadius(25)
            .padding()
        }
        .background(Color(.myWhite).edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.fetchMessages(with: selectedUser.id)
        }
        .navigationBarHidden(true) // Hide the navigation bar title
    }
}

struct UserListView: View {
    @EnvironmentObject var viewModel: AuthService
    
    var body: some View {
        NavigationView {
            List(viewModel.allUsers.filter { $0.id != viewModel.userSession?.uid }) { user in
                NavigationLink(destination: ChatView(selectedUser: user)
                    .environmentObject(viewModel)) {
                        HStack {
                            if let url = URL(string: user.profileImageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(user.fullname)
                                    .font(.headline)
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Select User to Chat")
            .onAppear {
                Task {
                    await viewModel.fetchAllUsers()
                }
            }
        }
        .background(Color(.myWhite).edgesIgnoringSafeArea(.all))
    }
}
