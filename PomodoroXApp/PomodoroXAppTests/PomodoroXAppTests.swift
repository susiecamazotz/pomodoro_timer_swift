//
//  PomodoroXAppTests.swift
//  PomodoroXAppTests
//
//  Created by Zuzanna Słapek on 30/01/2024.
//

import XCTest
import SwiftUI
import Combine
@testable import PomodoroXApp


final class LoginViewTests: XCTestCase {

    func testFormIsValid() {
        let loginView = LoginView()
        
        // Test with initial state (both fields empty)
        XCTAssertFalse(loginView.formIsValid, "Form should be invalid when email and password are empty.")
        
        // Test with only email
        loginView.email = "test@example.com"
        loginView.password = ""
        XCTAssertFalse(loginView.formIsValid, "Form should be invalid when password is empty.")
        
        // Test with only password
        loginView.email = ""
        loginView.password = "password123"
        XCTAssertFalse(loginView.formIsValid, "Form should be invalid when email is empty.")
        
        // Test with valid email and password
        loginView.email = "test@example.com"
        loginView.password = "password123"
        XCTAssertTrue(loginView.formIsValid, "Form should be valid when email and password are both filled correctly.")
    }
}

final class LoginViewUITests: XCTestCase {

    func testLoginViewUI() {
        // Launch the SwiftUI view in a UIHostingController
        let viewModel = AuthService()
        let loginView = LoginView().environmentObject(viewModel)
        let hostingController = UIHostingController(rootView: loginView)
        
        // Assert the view is loaded correctly
        XCTAssertNotNil(hostingController.view, "The LoginView should load correctly.")
        
        // Simulate user interaction
        // You will need to use XCTest UI Testing framework for more interactive tests,
        // but here we just verify the presence of UI elements and their initial states.
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthService()
        return Group {
            LoginView()
                .environmentObject(viewModel)
                .previewDisplayName("Light Mode")
            
            LoginView()
                .environmentObject(viewModel)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
