//
//  NounViewModel.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//
import SwiftUI
import SwiftCSV

class NounViewModel: BaseViewModel<Noun>  {
//    @Published var nouns: [Noun] = []
//    @Published var currentNounIndex: Int = 0

    @State var attempts: Int = 0
    @State  var shakeTrigger: CGFloat = 0
    
    private var history: [Int] = []

    override init() {
        super.init()
    }

    func getLocalCSVPath() -> URL? {
        if let path = Bundle.main.url(forResource: "nouns", withExtension: "csv") {
            return path
        }
        return nil
    }

    override func loadCSV() {
        let fileManager = FileManager.default
        if let localPath = getLocalCSVPath(), fileManager.fileExists(atPath: localPath.path) {
            loadCSV(from: localPath)
        } else if let bundledPath = Bundle.main.url(forResource: "nouns", withExtension: "csv") {
            loadCSV(from: bundledPath)
        }
    }

    func loadCSV_old(from url: URL) {
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            let lines = data.components(separatedBy: "\n").dropFirst()
            items = lines.compactMap { line in
                let columns = line.components(separatedBy: ",")
                if columns.count > 1 {
                    return Noun(meaning: columns[6].trimmingCharacters(in: .whitespacesAndNewlines),
                                fullWord: columns[4].trimmingCharacters(in: .whitespacesAndNewlines),
                                plural: columns[5].trimmingCharacters(in: .whitespacesAndNewlines),
                                gender: columns[2].trimmingCharacters(in: .whitespacesAndNewlines))
                }
                return nil
            }
            items.shuffle()
        } catch {
            print("Error loading CSV: \(error)")
        }
    }
    
    func loadCSV(from url: URL) {
        do {
            let csv = try CSV<Enumerated>(url: url, delimiter: ",", encoding: .utf8)
            items = csv.rows.compactMap { row in
                if row.count > 6 { // Ensure enough columns exist
                    return Noun(
                        meaning: row[6].trimmingCharacters(in: .whitespacesAndNewlines),
                        fullWord: row[4].trimmingCharacters(in: .whitespacesAndNewlines),
                        plural: row[5].trimmingCharacters(in: .whitespacesAndNewlines),
                        gender: row[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }
                return nil
            }
            items.shuffle()
        } catch {
            print("Error loading CSV: \(error)")
        }
    }

    func checkAnswer() -> Bool {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedAnswer = items[currentIndex].fullWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let correct = trimmedInput == trimmedAnswer
        if correct {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            failedAttempts = 0
            showFirework = true // Trigger animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.showFirework = false // Hide after 1 second
            }
        } else {
            failedAttempts += 1
//            shake(duration: 1.0)
        }

        return correct
    }

    func nextNoun() {
        userInput = ""
        var newIndex: Int
        
        // Select a new noun that's not in the history
        repeat {
            newIndex = Int.random(in: 0..<items.count)
        } while history.contains(newIndex) || items[newIndex].meaning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        currentIndex = newIndex
        failedAttempts = 0 // Reset failed attempts
        
        // Update history
        history.append(currentIndex)
        if history.count > 30 {
            history.removeFirst() // Maintain the last 30 words
        }
    }
    
    func getCustomBackGroundColor() -> Color {
        guard isCorrect else { return .yellow }
        switch items[currentIndex].gender {
        case "M": return Color(hex: "#FFA12F")  // DER: Orange or #FF9D0A" FB9901
        case "F": return Color(hex: "#33488F")  // DIE: Blue
        case "N": return Color(hex: "#D8A8D6")  // DAS: Purple - Violet
        default: return .yellow
        }
    }
    
    func getCustomTextColor() -> Color {
        guard isCorrect else { return .yellow }
        switch items[currentIndex].gender {
        case "M": return Color(hex: "#B73F00")  // DER: Orange or #FF9D0A" FB9901
        case "F": return Color(hex: "#0CE5EA")  // DIE: Blue
        case "N": return Color(hex: "#9E25A6")  // DAS: Purple - Violet
        default: return .yellow
        }
    }
    
    func shake(duration: Double = 0.5) {
        withAnimation(.linear(duration: duration)) {
            shakeTrigger += 1
        }
    }
    
}
