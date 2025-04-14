//
//  SentencePuzzleView.swift
//  weisswein
//
//  Created by Phuc on 8/4/25.
//
import SwiftUI

struct SentencePuzzleView: View {
    @StateObject private var viewModel = SenViewModel()

    @State private var selectedWords: [String] = []
    @State private var shuffledWords: [String] = []
    @State private var correctAnswerWords: [String] = []
    @State private var showIncorrect = false

    @State private var selectedWordsLine1: [String] = []
    @State private var selectedWordsLine2: [String] = []
    @State private var len1: CGFloat=0
    @State private var len2: CGFloat=0
    
    @State private var effectTrigger: Int=0
    @State private var wrongTrigger = false
    
    @State private var checked = false
    @State private var showingSettings = false
    var body: some View {
        ZStack() {
            ZStack {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 30))
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.black)
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(
                        senViewModel: SenViewModel(),
                        nounViewModel: NounViewModel(),
                        verbViewModel: VerbViewModel()
                    )
                }
                .position(x: 40, y: 15)
                Divider()
                    .background(Color.gray)
                    .position(x: 200, y:35)
            }
            VStack(spacing: 20) {
                Text(viewModel.items[viewModel.currentIndex].english)
                    .font(.system(size: 36))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(wrongTrigger ? .red : .black)
                
                // Answer line
                VStack {
                    HStack {
                        ForEach(selectedWordsLine1, id: \.self) { word in
                            Text(word)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                            //                        .padding(10)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .onTapGesture {
                                    if len1 < 200 || selectedWordsLine2.isEmpty {
                                        if let index = selectedWordsLine1.firstIndex(of: word) {
                                            let removed = selectedWordsLine1.remove(at: index)
                                            len1 = len1 - getWordWidth(word: removed) - getWordWidth(word: " ")
                                            print(len1)
                                            //                                    shuffledWords.append(removed)
                                            //                                    shuffledWords.shuffle()
                                        }
                                    }
                                }
                        }
                    }
                    HStack {
                        ForEach(selectedWordsLine2, id: \.self) { word in
                            Text(word)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                            //                        .padding(10)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .onTapGesture {
                                    if !selectedWordsLine2.isEmpty {
                                        if let index = selectedWordsLine2.firstIndex(of: word) {
                                            let removed = selectedWordsLine2.remove(at: index)
                                            len1 = len1 - getWordWidth(word: removed) - getWordWidth(word: " ")
                                            print(len1)
                                            //                                    shuffledWords.append(removed)
                                            //                                    shuffledWords.shuffle()
                                        }
                                    }
                                    
                                }
                        }
                    }
                    //            .padding(.vertical, 40)
                    //            .padding(.horizontal, 190)
                    //            .position(x: 5, y: 5)
                    
                    
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                
                // Word bank
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 3), spacing: 10) {
                    ForEach(shuffledWords, id: \.self) { word in
                        Text(word)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(
                                selectedWordsLine1.contains(word) || selectedWordsLine2.contains(word)
                                ? Color.gray
                                : Color.black
                            )
                            .cornerRadius(10)
                            .onTapGesture {
                                if let index = shuffledWords.firstIndex(of: word) {
                                    //                                let removed = shuffledWords.remove(at: index)
                                    
                                    len1 = len1 + getWordWidth(word: word) + getWordWidth(word: " ")
                                    print("len 1:", len1)
                                    if len1 < 200 {
                                        //                                    selectedWords.append(removed)
                                        selectedWordsLine1.append(word)
                                    } else {
                                        //                                    selectedWords.append(removed)
                                        selectedWordsLine2.append(word)
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }
                    }
                }
                .padding()
                .animation(nil, value: shuffledWords)
                .confettiCannon(trigger: $effectTrigger, num: 50, rainHeight:100, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 180), radius: 300, hapticFeedback: true)
                
                //            if showIncorrect {
                //                wrongTrigger = true
                //            }
                
                HStack(spacing: 20) {
                    Button(action: {
                        let correct = viewModel.items[viewModel.currentIndex].german
                        let trimmedCorrect = correct.trimmingCharacters(in: .whitespacesAndNewlines)
                        let sanitizedCorrect = trimmedCorrect.components(separatedBy: .whitespaces)
                        selectedWords = selectedWordsLine1 + selectedWordsLine2
                        checked = true
                        if checkAnswer(userInput: selectedWords.joined(separator: " ")) {
                            showIncorrect = false
                            wrongTrigger = false
                            effectTrigger += 1
                        } else {
                            showIncorrect = true
                            wrongTrigger = true
                            //                        withAnimation {
                            //                            shuffledWords.append(contentsOf: selectedWords)
                            //                            selectedWords.removeAll()
                            //                            shuffledWords.shuffle()
                            //                        }
                        }
                    }) {
                        Label("Check", systemImage: "checkmark.arrow.trianglehead.counterclockwise")
                    }
                    .font(.system(size:20))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color(hex: "F5F5F5"))
                    .foregroundColor(.green)
                    
                    .clipShape(Capsule())
                    
                    Button(action: {
                        
                        if !checked {
                            selectedWords = selectedWordsLine1 + selectedWordsLine2
                            if checkAnswer(userInput: selectedWords.joined(separator: " ")) {
                                showIncorrect = false
                                wrongTrigger = false
                                effectTrigger += 1
                            } else {
                                showIncorrect = true
                                wrongTrigger = true
                            }
                            checked = true
                        } else {
                            if viewModel.nextSentence() {
                                resetPuzzle()
                                showIncorrect = false
                                wrongTrigger = false
                                len1 = 0
                            }
                            checked = false
                        }
                        
                    }) {
                        Label("Next", systemImage: "arrow.right.circle.fill")
                        
                    }
                    .font(.system(size:20))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color(hex: "F5F5F5"))
                    //                    .buttonStyle(.bordered)
                    .foregroundColor(.black)
                    //                    .frame(width: 200, height: 200)
                    //                    .cornerRadius(50)
                    .clipShape(Capsule())
                    
                }
                .padding(.top)
            }
            .onAppear {
                resetPuzzle()
            }
        }
    }
    
    func checkAnswer(userInput: String) -> Bool {
        let correctAns = viewModel.items[viewModel.currentIndex].german
        
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
        let trimmedAnswer = correctAns.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }

        let correct = trimmedInput == trimmedAnswer
        if correct {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
//            failedAttempts = 0
        } else {
        }
        return correct
    }

    func resetPuzzle() {
        let sentence = viewModel.items[viewModel.currentIndex].german
        let words = sentence.splitToWordsKeepingPunctuation()
        correctAnswerWords = words
        shuffledWords = words.shuffled()
        selectedWords.removeAll()
        selectedWordsLine1.removeAll()
        selectedWordsLine2.removeAll()
    }
    
    func addWordToSelected(word: String) {
        let wordWidth = getWordWidth(word: word)
        let currentWidthLine1 = selectedWordsLine1.reduce(0) { $0 + getWordWidth(word: $1) }
        let currentWidthLine2 = selectedWordsLine2.reduce(0) { $0 + getWordWidth(word: $1) }

        if currentWidthLine1 + wordWidth < UIScreen.main.bounds.width {
            selectedWordsLine1.append(word)
        } else if currentWidthLine2 + wordWidth < UIScreen.main.bounds.width {
            selectedWordsLine2.append(word)
        }
    }

    func moveWordBackToShuffled(word: String) {
        if let index = selectedWordsLine1.firstIndex(of: word) {
            selectedWordsLine1.remove(at: index)
        } else if let index = selectedWordsLine2.firstIndex(of: word) {
            selectedWordsLine2.remove(at: index)
        }
        shuffledWords.append(word)
        shuffledWords.shuffle()
    }

    func getWordWidth(word: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 16) // Use the same font size as your view
        let size = (word as NSString).size(withAttributes: [.font: font])
        return size.width
    }
}

// Helper to split while preserving punctuation
extension String {
    func splitToWordsKeepingPunctuation() -> [String] {
        let pattern = "[\\wäöüßÄÖÜ]+[’'\",;:.!?]*"
        let regex = try! NSRegularExpression(pattern: pattern)
        let nsString = self as NSString
        let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range) }
    }
}

struct SentencePuzzleView_Previews: PreviewProvider {
    static var previews: some View {
        SentencePuzzleView()
    }
}
