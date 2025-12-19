//
//  AboutView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 30/08/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // App Icon and Title Section
                VStack(spacing: 16) {
                    Image(systemName: "figure.martial.arts")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 100, height: 100)
                        )

                    Text("Shōtōkan Kata")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Traditional Karate Learning")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                Divider()

                // About Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)

                    Text("Shōtōkan Kata is a comprehensive learning platform for traditional Shōtōkan karate practitioners. This app provides detailed information about authentic JKA (Japan Karate Association) kata, including complete move sequences, Japanese terminology, and proper pronunciation guides.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Whether you're a beginner learning your first kata or an advanced practitioner reviewing complex sequences, this app serves as your digital companion for mastering the art of Shōtōkan karate.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Special thanks to Malene Kirkeby sensei, a multiple WUKF world championship gold medalist, for her exceptional kata work and dedication to the art of Shōtōkan karate. Some of her work is found in this app.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.secondary)
                        .italic()
                }

                Divider()

                // Features Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRowView(
                            icon: "book.fill",
                            title: "Complete Kata Database",
                            description: "Detailed information for all traditional JKA Shōtōkan kata"
                        )

                        FeatureRowView(
                            icon: "textformat.alt",
                            title: "Authentic Japanese Terminology",
                            description: "Proper technique names with hiragana pronunciation guides"
                        )

                        FeatureRowView(
                            icon: "list.number",
                            title: "Step-by-Step Sequences",
                            description: "Complete move breakdowns with stances and directions"
                        )

                        FeatureRowView(
                            icon: "graduationcap.fill",
                            title: "Rank-Based Organization",
                            description: "Kata organized by traditional Kyu and Dan rank progression"
                        )

                        FeatureRowView(
                            icon: "questionmark.circle.fill",
                            title: "Knowledge Testing",
                            description: "Quiz system to test your understanding of kata and techniques"
                        )
                    }
                }

                Divider()

                // Tradition Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Respect for Tradition")
                        .font(.headline)

                    Text("This app seeks to honor the traditional teachings of Shōtōkan karate as refined by the Japan Karate Association (JKA). All kata information follows authentic JKA curriculum standards, ensuring practitioners learn with respect for the art's rich heritage. In case of doubt the please refer to your instructor or official JKA resources - e.g. the books \"Karate-dō kata\" volumes 1-4 by Japan Karate Association.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .italic()
                }

                Divider()

                // Open Source Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Open Source")
                        .font(.headline)

                    Text("This app is open source and available on GitHub. Feel free to explore the code, contribute improvements, or use it as a learning resource.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    Link("View on GitHub", destination: URL(string: "https://github.com/jenslohmann/ShotokanKata")!)
                        .font(.body)
                        .foregroundColor(.blue)
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Feature Row View
struct FeatureRowView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
