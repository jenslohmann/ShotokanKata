//
//  Extensions.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - String Extensions
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

// MARK: - Array Extensions
extension Array where Element == String {
    func formattedList() -> String {
        if isEmpty { return "" }
        if count == 1 { return first! }
        if count == 2 { return "\(first!) & \(last!)" }

        let allButLast = dropLast().joined(separator: ", ")
        return "\(allButLast) & \(last!)"
    }
}

// MARK: - Color Extensions
extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)

    // Belt rank colors
    static let beltYellow = Color.yellow
    static let beltOrange = Color.orange
    static let beltGreen = Color.green
    static let beltPurple = Color.purple
    static let beltBrown = Color(red: 0.6, green: 0.4, blue: 0.2)
    static let beltBlack = Color.black
    static let beltWhite = Color.white
}
