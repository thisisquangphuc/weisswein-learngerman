//
//  Sentence.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//

import Foundation

struct Sentence: Identifiable {
    let id = UUID()
    let english: String
    let german: String
    let germanExtra: String
}

struct Noun: Identifiable {
    let id = UUID()
    let meaning: String
    let fullWord: String
    let plural: String
    let gender: String
}

struct VerbConjugation: Identifiable {
    let id = UUID()
    let meaning: String
    let infinitive: String
    let ich: String
    let du: String
    let er_sie_es: String
    let wir: String
    let ihr: String
    let Sie: String
    let checks: [Bool]  // Stores check statuses
    
    var checkCount: Int {
        checks.filter { $0 }.count  // Count number of TRUE values
    }
    
    var weight: Int {
        max(1, 5 - checkCount)  // 5 TRUE → 1 chance, 0 TRUE → 5 chances
    }
}
