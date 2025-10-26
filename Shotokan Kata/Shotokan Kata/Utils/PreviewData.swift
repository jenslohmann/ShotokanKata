//
//  PreviewData.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import Foundation

enum PreviewData {
    static let sampleKata = Kata(
        name: "Heian Shodan",
        japaneseName: "平安初段",
        hiraganaName: "へいあん しょだん",
        numberOfMoves: 21,
        kataNumber: 1,
        beltRank: "9_kyu",
        description: "The first kata in the Heian series, teaching basic blocks and punches in a simple linear pattern.",
        keyTechniques: ["Gedan-barai", "Oi-zuki", "Age-uke", "Gyaku-zuki"],
        referenceURL: "https://www.example.com",
        moves: [
            KataMove(
                sequence: 1,
                japaneseName: "Hidari gedan-barai",
                direction: "West",
                kiai: false,
                subMoves: [
                    KataSubMove(
                        order: 1,
                        technique: "Hidari gedan-barai",
                        hiragana: "ひだり げだんばらい",
                        stance: "Zenkutsu-dachi",
                        stanceHiragana: "ぜんくつだち",
                        description: "Turn left 90° into front stance with left downward block",
                        icon: "shield.lefthalf.filled",
                        kiai: nil
                    )
                ],
                sequenceName: nil
            )
        ]
    )
}
