import SwiftUI
import FirebaseAuth

struct MessageBubble: View {
    var message: AuthService.Message
    @State private var showTime = false
    @EnvironmentObject var viewModel: AuthService
    
    var body: some View {
        VStack(alignment: message.senderId == Auth.auth().currentUser?.uid ? .trailing : .leading) {
            HStack {
                Text(message.text)
                    .foregroundColor(.white)
                    .padding()
                    .background(message.senderId == Auth.auth().currentUser?.uid ? Color(.greenButton) : Color(.lightGreen))
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: message.senderId == Auth.auth().currentUser?.uid ? .trailing : .leading)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.senderId == Auth.auth().currentUser?.uid ? .trailing : .leading, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.senderId == Auth.auth().currentUser?.uid ? .trailing : .leading)
        .padding(message.senderId == Auth.auth().currentUser?.uid ? .trailing : .leading)
        .padding(.horizontal, 10)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message: AuthService.Message(id: "12345", text: "I've been coding applications from scratch in SwiftUI and it's so much fun!", senderId: "otherUserId", timestamp: Date()))
    }
}
