import XCTest
import SwiftUI
@testable import PomodoroXApp

class LoginViewTests: XCTestCase {
    func testFormIsValid_whenEmailIsInvalid() {
        let view = LoginView()
        view.email = "invalid-email"
        view.password = "password"
        
        XCTAssertFalse(view.formIsValid, "The form should be invalid when email is not properly formatted")
    }
    
    func testFormIsValid_whenPasswordIsEmpty() {
        let view = LoginView()
        view.email = "test@example.com"
        view.password = ""
        
        XCTAssertFalse(view.formIsValid, "The form should be invalid when password is empty")
    }
}

class RegistrationViewTests: XCTestCase {
    
    var registrationView: RegistrationView!
    
    override func setUp() {
        super.setUp()
        registrationView = RegistrationView()
    }
    
    override func tearDown() {
        registrationView = nil
        super.tearDown()
    }
    
    func testEmailValidation() {
        // Invalid email (empty)
        registrationView.password = "password123"
        registrationView.fullname = "Test User"
        registrationView.username = "testuser"
        registrationView.email = ""
        XCTAssertFalse(registrationView.formIsValid)
        
        // Invalid email (missing @)
        registrationView.email = "testexample.com"
        XCTAssertFalse(registrationView.formIsValid)
    }
    
    func testPasswordValidation() {
        // Invalid password (empty)
        registrationView.email = "test@example.com"
        registrationView.fullname = "Test User"
        registrationView.username = "testuser"
        registrationView.password = ""
        XCTAssertFalse(registrationView.formIsValid)
        
        // Invalid password (too short)
        registrationView.password = "12345"
        XCTAssertFalse(registrationView.formIsValid)
    }
    
    func testFullnameValidation() {
        // Invalid fullname (empty)
        registrationView.email = "test@example.com"
        registrationView.password = "password123"
        registrationView.username = "testuser"
        registrationView.fullname = ""
        XCTAssertFalse(registrationView.formIsValid)
    }
    
    func testUsernameValidation() {
        // Invalid username (empty)
        registrationView.email = "test@example.com"
        registrationView.password = "password123"
        registrationView.fullname = "Test User"
        registrationView.username = ""
        XCTAssertFalse(registrationView.formIsValid)
    }
}
