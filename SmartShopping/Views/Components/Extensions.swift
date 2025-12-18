//
//  Extensions.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

// Color extension for custom colors
extension Color {
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
}

// View extensions for common modifiers
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Date formatting extension
extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// String extension for validation
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var isStrongPassword: Bool {
        // At least 8 characters, one uppercase, one lowercase, one digit
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: self)
    }
}
