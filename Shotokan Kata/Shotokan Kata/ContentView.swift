//
//  ContentView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab = 0 // 0 = Kata tab, 1 = Quiz tab, 2 = About tab

    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone layout with TabView
            TabView(selection: $selectedTab) {
                NavigationStack {
                    KataListView()
                }
                .tabItem {
                    Image(systemName: "figure.martial.arts")
                    Text(NSLocalizedString("nav.kata", comment: "Kata tab"))
                }
                .tag(0)

                NavigationStack {
                    QuizMenuView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Image(systemName: "questionmark.circle")
                    Text(NSLocalizedString("nav.quiz", comment: "Quiz tab"))
                }
                .tag(1)

                NavigationStack {
                    AboutView()
                }
                .tabItem {
                    Image(systemName: "info.circle")
                    Text(NSLocalizedString("nav.about", comment: "About tab"))
                }
                .tag(2)
            }
        } else {
            // iPad layout with NavigationSplitView
            NavigationSplitView {
                SidebarView()
                    .navigationTitle("Shōtōkan Kata")
            } detail: {
                NavigationStack {
                    KataListView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
