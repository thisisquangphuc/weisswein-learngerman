//
//  BaseViewModel.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SwiftCSV

class BaseViewModel<T: Identifiable>: ObservableObject {
    @Published var items: [T] = []
    @Published var currentIndex: Int = 0
    @Published var userInput: String = ""
    @Published var isCorrect: Bool = false
    @Published var showFirework: Bool = false
    @Published var failedAttempts: Int = 0
    private var history: [Int] = []
    
    init() {
        loadCSV()
        shuffleData()
    }
    
    func loadCSV() {
        // This function should be overridden by subclasses
        fatalError("loadCSV() must be implemented in subclasses")
    }
    
    func shuffleData() {
        items.shuffle()
    }
    
    func checkAnswer(correctAnswer: String) -> Bool {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
        let trimmedAnswer = correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }

        let correct = trimmedInput == trimmedAnswer
        if correct {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            failedAttempts = 0
        } else {
            failedAttempts += 1
        }
        return correct
    }
    
    func nextItem() {
        userInput = ""
        var newIndex: Int
        repeat {
            newIndex = Int.random(in: 0..<items.count)
        } while history.contains(newIndex)
        
        currentIndex = newIndex
        failedAttempts = 0

        history.append(currentIndex)
        if history.count > 30 {
            history.removeFirst()
        }
    }
    
//    func getDocumentsDirectory() -> URL? {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//    }
//    
//    func saveCSV(fileURL: URL, fileType: String) {
//        let fileManager = FileManager.default
//        var targetFileName: String
//
//        switch fileType {
//        case "Verb":
//            targetFileName = "Verb.csv"
//        case "Sentence":
//            targetFileName = "Sentences.csv"
//        case "Noun":
//            targetFileName = "Nouns.csv"
//        case "Note":
//            targetFileName = "Notes.csv"
//        default:
//            print("Invalid file type selected")
//            return
//        }
//
//        if let destinationURL = getDocumentsDirectory()?.appendingPathComponent(targetFileName) {
//            do {
//                if fileManager.fileExists(atPath: destinationURL.path) {
//                    try fileManager.removeItem(at: destinationURL)
//                }
//                try fileManager.copyItem(at: fileURL, to: destinationURL)
//                loadCSV()  // Reload data after importing
//            } catch {
//                print("Error copying CSV file: \(error)")
//            }
//        }
//    }
    
}
