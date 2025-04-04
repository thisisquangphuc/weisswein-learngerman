import SwiftUI
import ConfettiSwiftUI

struct VerbsView: View {
    @StateObject private var viewModel = VerbViewModel()
    @State private var userInputs: [String] = Array(repeating: "", count: 7) // Include infinitive
    @State private var isCorrect: [Bool?] = Array(repeating: nil, count: 7)
    @State private var showConfetti = false
    @State private var showingHint = false
    
    @State private var confettiTrigger: Int = 0

    let pronouns = ["Infinitive", "Ich", "Du", "Er/Sie/Es", "Ihr"]

    var body: some View {
        ZStack {
            // Title Bar
            Spacer()
            VStack {
                Text(viewModel.items[viewModel.currentIndex].meaning)
                    .font(.title)
                    .bold()
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                //                    .background(Color.blue)
                
                
                // Input Fields
                ForEach(0..<5, id: \.self) { index in
                    HStack {
                        Text(pronouns[index])
                            .bold()
                        
                        TextField("Enter \(pronouns[index]) form", text: $userInputs[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .cornerRadius(8)
                            .foregroundColor(isCorrect[index] == nil ? Color.black : (isCorrect[index]! ? Color.green: Color.red))
                        //                        .background(isCorrect[index] == nil ? Color.clear : (isCorrect[index]! ? Color.green.opacity(0.3) : Color.red.opacity(0.3)))
                            .onSubmit {
                                checkAnswer(for: index)
                            }
                            .confettiCannon(trigger: $confettiTrigger, confettiSize: 10, repetitions: 1, repetitionInterval: 0.7)
                        
                    }
                }
                
                if showConfetti {
                    FireworkView() // Assuming FireworkView is a confetti effect
                }
                
                Button("Next Verb") {
                    viewModel.nextVerb()
                    userInputs = Array(repeating: "", count: 7)
                    isCorrect = Array(repeating: nil, count: 7)
                    showConfetti = false
                }
                .buttonStyle(.bordered)
            }
            Spacer()
            
            if viewModel.failedAttempts >= 1 {
                Button(action: {
                    showingHint = true
                }) {
                    Text("Hint")
                        .font(.caption)
                        .padding(5)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .position(x: UIScreen.main.bounds.width - 50, y: 30) // Position in top-right corner
                .alert(isPresented: $showingHint) {
                    let current = viewModel.items[viewModel.currentIndex]
                    let hintMessage = """
                    Infinitive: \(current.infinitive)
                    Ich: \(current.ich)
                    Du: \(current.du)
                    Er/Sie/Es: \(current.er_sie_es)
                    Wir: \(current.wir)
                    Ihr: \(current.ihr)
                    Sie: \(current.Sie)
                    """
                    
                    return Alert(
                        title: Text("Hint"),
                        message: Text(hintMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .padding()
    }

    private func checkAnswer(for index: Int) {
            viewModel.userInput = userInputs[index]
            switch index {
            case 0:  // Infinitive
                isCorrect[index] = viewModel.checkInfinitiveAnswer()
            case 1:  // Ich
                isCorrect[index] = viewModel.checkIchAnswer()
            case 2:  // Du
                isCorrect[index] = viewModel.checkDuAnswer()
            case 3:  // Er/Sie/Es
                isCorrect[index] = viewModel.checkErSieEsAnswer()
            case 4:  // Ihr
                isCorrect[index] = viewModel.checkIhrAnswer()
            default:
                break
            }
        if isCorrect[index] == true {
            confettiTrigger += 1
        }
            
            // Check if all answers are correct
            if isCorrect.allSatisfy({ $0 == true }) {
                showConfetti = true
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success) // Long haptic feedback
            }
        }
}

struct VerbPreviews: PreviewProvider {
    static var previews: some View {
        VerbsView()
    }
}
