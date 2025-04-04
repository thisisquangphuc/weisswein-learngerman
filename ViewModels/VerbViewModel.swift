//
//  SenViewModel.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//


import SwiftUI
import SwiftCSV

class VerbViewModel: BaseViewModel<VerbConjugation> {
//    @Published var sentences: [Sentence] = []
//    @Published var currentSentenceIndex: Int = 0

    private var history: [Int] = []
    
    override init() {
        super.init()
    }
    
    func getLocalCSVPath() -> URL? {
        if let path = Bundle.main.url(forResource: "verbs", withExtension: "csv") {
            return path
        }
        return nil
    }
    
    override func loadCSV() {
        let fileManager = FileManager.default
        if let localPath = getLocalCSVPath(), fileManager.fileExists(atPath: localPath.path) {
            loadCSV(from: localPath)
        } else if let bundledPath = Bundle.main.url(forResource: "verbs", withExtension: "csv") {
            loadCSV(from: bundledPath)
        }
    }

    func loadCSV(from url: URL) {
        do {
            let csv = try CSV<Enumerated>(url: url, delimiter: ",", encoding: .utf8)
            
            items = csv.rows.compactMap { row in
                 let meaning = row[0].trimmingCharacters(in: .whitespacesAndNewlines)
                 let infinity = row[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
            
                // Extract conjugations safely
                let conjugations = [
                    row[2], row[3], row[4], row[5], row[6],
                    row[7], row[8], row[9]
                ].compactMap { $0?.trimmingCharacters(in: .whitespaces) }
                
                // Extract check values safely
                let checkValues = [
                    row[10], row[11], row[12],
                    row[13], row[14]
                ].map { $0?.trimmingCharacters(in: .whitespaces).lowercased() == "true" }
                
                let checkCount = checkValues.filter { $0 }.count
                
                return VerbConjugation(
                    meaning: meaning,
                    infinitive: infinity,  // Corrected name to match struct
                    ich: conjugations[0],
                    du: conjugations[1],
                    er_sie_es: conjugations[2],
                    wir: conjugations[3],
                    ihr: conjugations[4],
                    Sie: conjugations[5],
                    checks: checkValues  // Mapping check values correctly
                )
            }
            items.shuffle() // Shuffle the items after loading
            
        } catch {
            print("Error loading CSV: \(error)")
        }
    }
    
    func saveCSV(fileURL: URL) {
        let fileManager = FileManager.default
        if let destinationURL = getLocalCSVPath() {
            do {
                try fileManager.copyItem(at: fileURL, to: destinationURL)
                loadCSV()  // Reload data after importing
            } catch {
                print("Error copying CSV file: \(error)")
            }
        }
    }
    
    // Check the infinitive form
    func checkInfinitiveAnswer() -> Bool {
        return checkAnswer(correctAnswer: items[currentIndex].infinitive)
    }
    
    // Check the "ich" form
    func checkIchAnswer() -> Bool {
        return checkAnswer(correctAnswer: items[currentIndex].ich)
    }

    // Check the "du" form
    func checkDuAnswer() -> Bool {
        return checkAnswer(correctAnswer: items[currentIndex].du)
    }

    // Check the "er/sie/es" form
    func checkErSieEsAnswer() -> Bool {
        return checkAnswer(correctAnswer: items[currentIndex].er_sie_es)
    }

    // Check the "wir" and "Sie" forms (since they share the same conjugation)
    func checkWirSieAnswer() -> Bool {
        return checkAnswer(correctAnswer: items[currentIndex].wir) ||
               checkAnswer(correctAnswer: items[currentIndex].Sie)
    }

    // Check the "ihr" form
    func checkIhrAnswer() -> Bool {
        return checkAnswer(correctAnswer: items[currentIndex].ihr)
    }

    
    func nextVerb() {
        userInput = ""
        var newIndex: Int
        
        // Select a new sentence that's not in the history
        repeat {
            newIndex = Int.random(in: 0..<items.count)
        } while history.contains(newIndex) || items[newIndex].infinitive.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        currentIndex = newIndex
        
        failedAttempts = 0 // Reset failed attempts
        
        // Update history
        history.append(currentIndex)
        if history.count > 30 {
            history.removeFirst() // Maintain the last 30 words
        }
    }
}
