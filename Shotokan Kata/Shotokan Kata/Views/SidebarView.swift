//
//  SidebarView.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import SwiftUI

struct SidebarView: View {
    @State private var selectedView: SidebarItem? = .kata

    var body: some View {
        List(SidebarItem.allCases, id: \.self, selection: $selectedView) { item in
            NavigationLink(value: item) {
                Label(item.title, systemImage: item.systemImage)
            }
        }
        .navigationDestination(for: SidebarItem.self) { item in
            item.destination
        }
        .listStyle(.sidebar)
    }
}

enum SidebarItem: CaseIterable {
    case kata
    case quiz
    case about

    var title: String {
        switch self {
        case .kata:
            return NSLocalizedString("nav.kata", comment: "Kata")
        case .quiz:
            return NSLocalizedString("nav.quiz", comment: "Quiz")
        case .about:
            return NSLocalizedString("nav.about", comment: "About")
        }
    }

    var systemImage: String {
        switch self {
        case .kata:
            return "figure.martial.arts"
        case .quiz:
            return "questionmark.circle"
        case .about:
            return "info.circle"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .kata:
            KataListView()
        case .quiz:
            // For iPad navigation, we don't need tab switching functionality
            // Use a wrapper that provides a constant binding
            QuizMenuView(selectedTab: .constant(1))
        case .about:
            AboutView()
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
    } detail: {
        Text("Select an item")
    }
}
