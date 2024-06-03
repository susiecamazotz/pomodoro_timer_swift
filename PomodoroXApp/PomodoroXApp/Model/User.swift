//
//  User.swift
//  PomodoroXApp
//
//  Created by Zuzanna Słapek on 09/01/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let username: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let compoments = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: compoments)
        }
        
        return ""
    }
}
