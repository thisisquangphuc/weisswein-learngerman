import SwiftUI
import ConfettiSwiftUI

struct VerbsView: View {
    @StateObject private var viewModel = VerbViewModel()
    @State private var userInputs: [String] = Array(repeating: "", count: 5) // Include infinitive
    @State private var isCorrect: [Bool?] = Array(repeating: nil, count: 5)
    
    @State private var showingHint = false
    
    @State private var finalCongrats: Int = 0
    @State private var confettiTrigger: Int = 0

    let pronouns = ["Infinitive", "Ich", "Du", "Er/Sie/Es", "Ihr"]

    var body: some View {
        ZStack {
            // Title Bar
            Color(Color(hex: "#E7FCFF"))
                .edgesIgnoringSafeArea([.top, .bottom, .leading, .trailing])
            
            ZStack {
                
                VStack {

                    Text(viewModel.items[viewModel.currentIndex].meaning)
                        .font(.title)
                        .bold()
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: "#FFFBC4")) // Background color of the rectangle
                                .shadow(color: .gray, radius: 3, x: 0, y: 0.5) // Sharp shadow effect
                        )
                        .confettiCannon(trigger: $confettiTrigger, confettiSize: 7, rainHeight: 500, repetitions: 1, hapticFeedback: true)
                        .padding(.leading, 15)
                        .padding(.trailing, 20)
                    
                    // Input Fields
                    VStack {
                        ForEach(0..<5, id: \.self) { index in
                            HStack {
                                Text(pronouns[index])
                                    .bold()
                                    .frame(maxWidth: 100, alignment: .leading)
                                    .padding(.leading, 30)
                                
                                TextField("Enter \(pronouns[index]) form", text: $userInputs[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.top, 2)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .cornerRadius(5)
                                    .padding(.trailing, 10)
                                    .foregroundColor(isCorrect[index] == nil ? Color.black : (isCorrect[index]! ? Color.green: Color.red))
                                    .onSubmit {
                                        checkAnswer(for: index)
                                    }
                            }
                            .confettiCannon(trigger: $finalCongrats, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 300, hapticFeedback: true)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white) // Background color of the rectangle
                            .shadow(color: .gray, radius: 3, x: 0, y: 0) // Sharp shadow effect
                    )
                    .padding()

                    Button(action: {
                        viewModel.nextVerb()
                        userInputs = Array(repeating: "", count: 5)
                        isCorrect = Array(repeating: nil, count: 5)
                        
                    }) {
                        Label("Next Verb", systemImage: "arrow.right.circle.fill")
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Capsule())
                }
                
                

                if viewModel.failedAttempts >= 1 {
                    Button(action: {
                        showingHint = true
                    }) {
                        Label("Hint", systemImage: "lightbulb.fill")
                            .padding(5)
                            .background(Color.orange)
                            .foregroundColor(.white)
                        //                        .shadow(radius: 5)
                            .buttonStyle(.bordered)
                            .clipShape(Capsule())
                    }
                    .position(x: UIScreen.main.bounds.width - 75, y: 30) // Position in top-right corner
//                        .frame(maxWidth: .infinity, alignment: .trailing)
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
                } // if

            }
            .padding()
        }

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
//            print(isCorrect) // Enable for dubug
            // Check if all answers are correct
            if isCorrect.allSatisfy({ $0 == true }) {
                finalCongrats += 1
            }
        }
}

struct VerbPreviews: PreviewProvider {
    static var previews: some View {
        VerbsView()
    }
}
