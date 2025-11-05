//
//  VocabularyView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 07/10/2025.
//

import SwiftUI

struct VocabularyView: View {
    @StateObject private var viewModel = VocabularyViewModel()
    @State private var showingCategoryFilter = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter controls
                VStack(spacing: 12) {
                    // Search bar - matching Kata list style
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField(NSLocalizedString("vocabulary.search.placeholder", comment: "Search terms..."), text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())

                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    // Category filter
                    HStack {
                        Button(action: {
                            showingCategoryFilter = true
                        }) {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(viewModel.selectedCategory?.displayName ?? NSLocalizedString("vocabulary.filter.all", comment: "All Categories"))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Capsule())
                        }

                        Spacer()

                        if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
                            Button(NSLocalizedString("vocabulary.filter.clear", comment: "Clear")) {
                                viewModel.clearFilters()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .background(Color(.systemBackground))

                // Content
                if viewModel.filteredTerms.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "book.closed")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text(NSLocalizedString("vocabulary.empty.title", comment: "No terms found"))
                            .font(.headline)
                            .padding(.top)
                        Text(NSLocalizedString("vocabulary.empty.subtitle", comment: "Try adjusting your search or filter"))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.filteredTerms) { term in
                            NavigationLink(destination: VocabularyDetailView(term: term)) {
                                VocabularyTermRowView(term: term)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(NSLocalizedString("nav.vocabulary", comment: "Vocabulary"))
            .navigationBarTitleDisplayMode(.large)
        }
        .confirmationDialog(
            NSLocalizedString("vocabulary.filter.category", comment: "Select Category"),
            isPresented: $showingCategoryFilter
        ) {
            Button(NSLocalizedString("vocabulary.filter.all", comment: "All Categories")) {
                viewModel.selectedCategory = nil
            }

            ForEach(viewModel.availableCategories, id: \.self) { category in
                Button(category.displayName) {
                    viewModel.selectedCategory = category
                }
            }

            Button(NSLocalizedString("common.cancel", comment: "Cancel"), role: .cancel) { }
        }
    }
}
