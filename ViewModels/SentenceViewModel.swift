//
//  SentenceViewModel.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//

import SwiftUI
import SwiftCSV

class SenViewModel: BaseViewModel<Sentence> {
//    @Published var sentences: [Sentence] = []
//    @Published var currentSentenceIndex: Int = 0

    private var history: [Int] = []
    
    override init() {
        super.init()
    }
    
    func getLocalCSVPath() -> URL? {
        if let path = Bundle.main.url(forResource: "GerSentences", withExtension: "csv") {
            return path
        }
        return nil
    }
    
    override func loadCSV() {
        let fileManager = FileManager.default
        if let localPath = getLocalCSVPath(), fileManager.fileExists(atPath: localPath.path) {
            loadCSV(from: localPath)
        } else if let bundledPath = Bundle.main.url(forResource: "GerSentences", withExtension: "csv") {
            loadCSV(from: bundledPath)
        }
    }

    func loadCSV(from url: URL) {
        do {
            let csv = try CSV<Named>(url: url, delimiter: ",", encoding: .utf8)
            items = csv.rows.compactMap { row in
                guard let english = row["English"],
                      let german = row["German"],
                      let germanExtra = row["German example 2"] else { return nil }
                return Sentence(english: english.trimmingCharacters(in: .whitespacesAndNewlines),
                                german: german.trimmingCharacters(in: .whitespacesAndNewlines),
                                germanExtra: germanExtra.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            items.shuffle()
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
    
    func checkSentenceAnswer() -> Bool {
        return checkAnswer(correctAnswer: items[currentIndex].german)
    }
    
    func nextSentence() {
        userInput = ""
        var newIndex: Int
        
        // Select a new sentence that's not in the history
        repeat {
            newIndex = Int.random(in: 0..<items.count)
        } while history.contains(newIndex) || items[newIndex].english.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        currentIndex = newIndex
        
        failedAttempts = 0 // Reset failed attempts
        
        // Update history
        history.append(currentIndex)
        if history.count > 30 {
            history.removeFirst() // Maintain the last 30 words
        }
    }
}
