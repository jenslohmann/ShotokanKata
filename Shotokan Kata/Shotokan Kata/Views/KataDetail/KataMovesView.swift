//
//  KataMovesView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataMovesView: View {
    let kata: Kata

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedMoves, id: \.sequence) { move in
                    KataMoveRowView(move: move)
                }
            }
            .padding()
        }
    }

    private var sortedMoves: [KataMove] {
        kata.moves.sorted { $0.sequence < $1.sequence }
    }
}
