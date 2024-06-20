//
//  AuthService.swift
//  PomodoroXApp
//
//  Created by Zuzanna Słapek on 10/01/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Combine
import FirebaseAuth

@MainActor
class AuthService: ObservableObject {
    @Published var allSessionsData: [UserSessionData] = []
    @Published var allUsers: [User] = []
    @Published var sessionsData: [Session] = []
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var didSendEmail = false
    @Published var profileImage: UIImage?
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    
    let database = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        fetchSessions()
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchCurrentUser()
            await fetchAllUsers()
        }
    }
    
    
    // USERS
    
    // Sign in
    func singIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchCurrentUser()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
            throw error
        }
    }
    
    // Sign out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    // Create user
    func createUser(withEmail email: String, password: String, fullname: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid,
                            fullname: fullname,
                            email: email,
                            username: username,
                            profileImageUrl: "")
            let encodedUser = try Firestore.Encoder().encode(user)
            try await database.collection("users").document(user.id).setData(encodedUser)
            await fetchCurrentUser()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
            throw error
        }
    }
    
    // Send reset password to chosen email
    func sendPasswordResetEmail(toEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("DEBUG: Failed to send email with error \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch the current user
    func fetchCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await database.collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        if let profileImageUrl = snapshot.data()?["profileImageUrl"] as? String {
            self.profileImage = await downloadImage(from: profileImageUrl)
        }
    }
    
    // Fetch all users from Firestore
    func fetchAllUsers() async {
        do {
            let snapshot = try await database.collection("users").getDocuments()
            self.allUsers = snapshot.documents.compactMap { doc -> User? in
                try? doc.data(as: User.self)
            }
        } catch {
            print("DEBUG: Failed to fetch users with error \(error.localizedDescription)")
        }
    }
    
    
    // TIMER
    
    // Save timer data
    func saveWorkSession(duration: Int, userId: String) async throws {
        let workSessionData = [
            "duration": duration,
            "timestamp": Timestamp(date: Date())
        ] as [String : Any]
        _ = try await database.collection("users").document(userId).collection("workSessions").addDocument(data: workSessionData)
    }
    
    // Fetch timer data for current user
    func fetchSessions() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("DEBUG: User ID is nil")
            return
        }
        
        database.collection("users").document(userId).collection("workSessions").addSnapshotListener {
            querySnapshot, error in guard let documents = querySnapshot?.documents else {
                print("No documents or error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.sessionsData = documents.map { queryDocumentSnapshot -> Session in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                let duration = data["duration"] as? Int ?? 0
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                return Session(id: id, duration: duration, timestamp: timestamp)
            }
        }
    }
    
    // Fetch timer data for all users
    func fetchAllSessions() async {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        do {
            let usersSnapshot = try await database.collection("users").getDocuments()
            var userSessions = [UserSessionData]()
            
            for userDoc in usersSnapshot.documents {
                let userId = userDoc.documentID
                let userSessionsSnapshot = try await database.collection("users").document(userId).collection("workSessions")
                    .whereField("timestamp", isGreaterThan: oneWeekAgo)
                    .getDocuments()
                
                let totalDuration = userSessionsSnapshot.documents.reduce(0) { $0 + ($1.data()["duration"] as? Int ?? 0) }
                
                if let fullname = userDoc.data()["fullname"] as? String {
                    let userSessionData = UserSessionData(id: userId, fullname: fullname, totalDuration: totalDuration)
                    userSessions.append(userSessionData)
                }
            }
            
            // sort
            self.allSessionsData = userSessions.sorted { $0.totalDuration > $1.totalDuration }
            
        } catch {
            print("DEBUG: Error fetching sessions: \(error.localizedDescription)")
        }
    }
    
    
    // MESSAGES
    
    // Fetch messages between two users
    func fetchMessages(with userId: String) {
        guard let currentUserId = userSession?.uid else { return }
        let chatId = generateChatId(user1: currentUserId, user2: userId)
        
        database.collection("chats").document(chatId).collection("messages").order(by: "timestamp", descending: false).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                return
            }
            self.messages = querySnapshot?.documents.compactMap { document -> Message? in
                try? document.data(as: Message.self)
            } ?? []
            
            self.lastMessageId = self.messages.last?.id ?? ""
        }
    }
    
    // Send a message to a user
    func sendMessage(text: String, to userId: String) {
        guard let currentUserId = userSession?.uid else { return }
        let chatId = generateChatId(user1: currentUserId, user2: userId)
        let message = Message(id: "\(UUID())", text: text, senderId: currentUserId, timestamp: Date())
        
        do {
            try database.collection("chats").document(chatId).collection("messages").document(message.id).setData(from: message)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    // Helper function to generate a chat ID
    private func generateChatId(user1: String, user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
    
    
    // PROFILE IMAGE
    
    // Update profile image
    func updateProfileImage(image: UIImage) {
        guard let userId = self.userSession?.uid else { return }
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    return
                }
                
                if let profileImageUrl = url?.absoluteString {
                    Task { @MainActor in
                        self.updateUserProfileImageUrl(userId: userId, profileImageUrl: profileImageUrl)
                    }
                }
            }
        }
    }
    
    // Update an url of image
    func updateUserProfileImageUrl(userId: String, profileImageUrl: String) {
        let userRef = database.collection("users").document(userId)
        userRef.updateData(["profileImageUrl": profileImageUrl]) { error in
            if let error = error {
                print("Error updating profile image URL in Firestore: \(error.localizedDescription)")
            } else {
                Task { @MainActor in
                    await self.fetchCurrentUser() // Refresh current user data
                }
                print("Profile image URL successfully updated in Firestore")
            }
        }
    }
    
    // Download image from Storage
    func downloadImage(from url: String) async -> UIImage? {
        guard let imageURL = URL(string: url) else {
            print("Invalid URL string: \(url)")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: imageURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("Failed to fetch image, status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return nil
            }
            return UIImage(data: data)
        } catch {
            print("Error downloading image: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // STRUCTURES
    struct Session: Identifiable {
        var id: String
        var duration: Int
        var timestamp: Date
    }
    
    struct User: Identifiable, Codable {
        let id: String
        let fullname: String
        let email: String
        let username: String
        var profileImageUrl: String
        
        var initials: String {
            let formatter = PersonNameComponentsFormatter()
            if let compoments = formatter.personNameComponents(from: fullname) {
                formatter.style = .abbreviated
                return formatter.string(from: compoments)
            }
            return ""
        }
    }
    
    struct Message: Identifiable, Codable {
        var id: String
        var text: String
        var senderId: String
        var timestamp: Date
    }
}
