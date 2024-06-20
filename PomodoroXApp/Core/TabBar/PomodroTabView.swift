//
//  PomodroTabView.swift
//  PomodoroXApp
//
//  Created by Zuzanna Słapek on 11/01/2024.
//

import SwiftUI

struct PomodoroTabView: View {
    @EnvironmentObject var viewModel: AuthService
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .onAppear { selectedTab = 0 }
                .tag(0)
            
            TimerView()
                .tabItem { Label("Timer", systemImage: "timer") }
                .onAppear { selectedTab = 1 }
                .tag(1)
            
            StatisticsView()
                .tabItem { Label("Statistics", systemImage: "chart.bar") }
                .onAppear { selectedTab = 2 }
                .tag(2)
            
            FriendsView()
                .tabItem { Label("Friends", systemImage: "person.3.fill") }
                .onAppear { selectedTab = 3 }
                .tag(3)
            
            UserListView()
                .tabItem { Label("Messenger", systemImage: "message.fill") }
                .onAppear { selectedTab = 4 }
                .tag(4)
        }
        .accentColor(Color(.greenButton))
    }
}

struct PomodoroXApp: App {
    var body: some Scene {
        WindowGroup {
            PomodoroTabView()
                .environmentObject(AuthService()) // Injecting the AuthService
        }
    }
}

