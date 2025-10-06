//
//  DetailSectionPicker.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct DetailSectionPicker: View {
    @Binding var selectedSection: KataDetailView.DetailSection

    var body: some View {
        Picker("Detail Section", selection: $selectedSection) {
            ForEach(KataDetailView.DetailSection.allCases, id: \.rawValue) { section in
                Label(section.title, systemImage: section.icon)
                    .tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}
