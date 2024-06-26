import SwiftUI

struct TitleRow: View {
    var user: AuthService.User
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                }
                .foregroundColor(Color.greenButton)
            }
            
            Spacer()
            
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
                    .font(.title).bold()
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.horizontal)
    }
}
