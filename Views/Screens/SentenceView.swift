//
//  SentenceView.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//
import SwiftUI

struct SentenceView: View {
    @StateObject var viewModel = SenViewModel()
    @State private var showingFileImporter = false
    @State private var showingHint = false

    
    var body: some View {
        ZStack {
            // Background color changes based on correctness
            Color(viewModel.isCorrect ? Color(hex: "#008000") : .white)
//                .edgesIgnoringSafeArea(.all)  // Ensures the background color covers the entire screen
                .edgesIgnoringSafeArea([.top, .bottom, .leading, .trailing])
            
            VStack {
                Spacer() // Pushes content downward
                
                
                //Spacer() // Pushes the text to the top

                VStack {
                    Text(viewModel.items.isEmpty ? "Loading..." : viewModel.items[viewModel.currentIndex].english)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                    
                    TextField("Enter German translation", text: $viewModel.userInput, onCommit: {
                        viewModel.isCorrect = viewModel.checkSentenceAnswer() // Call checkAnswer when Enter is pressed
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                    .foregroundColor(.black)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                    Button("Next") {
                        viewModel.nextSentence()
                        viewModel.isCorrect = false
                    }
                    .padding(10)
                    .background(Color(hex: "#000080"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(maxHeight: .infinity, alignment: .center) // Ensures vertical centering
                
                Spacer() // Pushes content downward
            }
            .padding()
            
            Button(action: {
                showingFileImporter = true
            }) {
                Text("Import CSV")
                    .font(.caption)
                    .padding(5)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .position(x: 50, y: 30) // Move the button closer to the top-left corner
            // File importer to select a CSV file
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
                switch result {
                case .success(let url):
                    viewModel.saveCSV(fileURL: url) // Load CSV when selected
                case .failure(let error):
                    print("Failed to import file: \(error.localizedDescription)")
                }
            }
            
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
                    Alert(
                        title: Text("Hint"),
                        message: Text(viewModel.items[viewModel.currentIndex].german),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}
