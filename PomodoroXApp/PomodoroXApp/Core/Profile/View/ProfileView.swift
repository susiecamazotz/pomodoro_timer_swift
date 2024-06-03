import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthService
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        VStack {
            if let user = viewModel.currentUser {
                VStack(spacing: 20) {
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Change to fill the circle
                            .frame(width: 180, height: 180) // Increased size
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.lightGreenButton), lineWidth: 4))
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180) // Increased size
                            .foregroundColor(Color(.lightGreenButton))
                            .padding(.top)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    }
                    
                    Text(user.fullname)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.greenButton))
                    
                    Text(user.username)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(user.email)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                Spacer()
                
                Button {
                    viewModel.signOut()
                } label: {
                    Label("SIGN OUT", systemImage: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.greenButton))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .padding()
        .background(Color(.background).edgesIgnoringSafeArea(.all)) // Use custom background color
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(selectedImage: $inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        viewModel.updateProfileImage(image: inputImage)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthService())
    }
}
