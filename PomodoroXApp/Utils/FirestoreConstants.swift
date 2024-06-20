//
//  FirestoreConstants.swift
//  PomodoroXApp
//
//  Created by Zuzanna Słapek on 10/01/2024.
//

import Firebase

struct FirestoreConstants {
    private static let Root = Firestore.firestore()
    
    static let UserCollection = Root.collection("users")
}
