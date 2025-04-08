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
    @State private var showingTypeSelection = false
    
    @State private var showingHint = false
    @State private var gradientProgress: CGFloat = 0.0
    @State private var selectedFileType = ""
    @State private var selectedOption = 0
    @State private var showingNextAlert = false
    
    private let options = ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
    
    var body: some View {
        NavigationView {
            
            ZStack {
                // Background color changes based on correctness
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#E0F882"), Color(hex: "#38B789")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: UIScreen.main.bounds.height) // Adjust height as needed
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.black, .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: UIScreen.main.bounds.height)
                    .offset(y: -(1 - gradientProgress) * UIScreen.main.bounds.height) // Animate this offset to reveal the gradient
                )
                .animation(.easeIn(duration: 0.5), value: gradientProgress) // Animation for gradient reveal
                .edgesIgnoringSafeArea([.top, .bottom, .leading, .trailing])
                
                ZStack {
                    VStack {
                        if viewModel.isCorrect {
                            VStack {
                                Text(viewModel.items[viewModel.currentIndex].german)
                                    .font(.system(size: 30))
                                    .bold()
                                    .foregroundColor(Color(hex: "#061A74"))
                                
                                if viewModel.items[viewModel.currentIndex].germanExtra != "" {
                                    Text(viewModel.items[viewModel.currentIndex].germanExtra)
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                    //                                        .padding(.top, 3)
                                }
                            }
                            .multilineTextAlignment(.center)
                            Divider()
                                .background(Color.gray)
                            
                            //                }
                            //                .edgesIgnoringSafeArea(.top)
                            //                .frame(maxHeight: .infinity, alignment: .top)
                            //                .padding(.top, 200)
                                .padding(.bottom, 10)
                        }
                        
                        //                Spacer() // Pushes content downward
                        
                        //                VStack {
                        
                        Text(viewModel.items.isEmpty ? "Loading..." : viewModel.items[viewModel.currentIndex].english)
                            .font(.title)
                            .multilineTextAlignment(.center)
                        //                        .padding(.bottom, 10)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(
                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(hex: "#F5F5F5"))
                                    //                                        .shadow(color: .gray, radius: 3, x: 0, y: 0)
                                        .frame(width: geometry.size.width)
                                }
                            )
                        HStack {
                            Image(systemName: "text.cursor")
                                .foregroundColor(.black)
                            TextField("Enter German translation", text: $viewModel.userInput, onCommit: {
                                viewModel.isCorrect = viewModel.checkSentenceAnswer() // Call checkAnswer when Enter is pressed
                                gradientProgress = viewModel.isCorrect ? 1.0 : 0.0
                            })
                        }
                        .padding(10)
                        .foregroundColor(.black)
                        .textInputAutocapitalization(.never)
                        .background(Color(hex: "F5F5F5")) //CHatGPT IOS app color
                        .disableAutocorrection(true)
                        .cornerRadius(30)
                        //                    .shadow(radius: 3)
                        
                        Button(action: {
                            viewModel.isCorrect = false
                            gradientProgress = 0.0
                            let res = viewModel.nextSentence()
                            print(res)
                            if res == false {
                                showingNextAlert = true
                            } else {
                                viewModel.isCorrect = false
                                gradientProgress = 0.0
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
                        .alert(isPresented: $showingNextAlert) {
                            Alert(
                                title: Text("weisswein message"),
                                message: Text("There is no next sentence available."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        
                    }
                    //                .frame(maxHeight: .infinity, alignment: .center) // Ensures vertical centering
                    
                    Spacer() // Pushes content downward
                }
                .padding()
                
                ZStack {
                    NavigationLink(destination: SettingsView(
                        senViewModel: SenViewModel(),
                        nounViewModel: NounViewModel(),
                        verbViewModel: VerbViewModel()
                    )) {
                        Image(systemName: "line.3.horizontal")
                            .padding(8)
                            .font(.system(size: 30))
//                            .background(Color.green)
                            .foregroundColor(.black)
//                            .cornerRadius(10)
                    }
                    .position(x: 35, y: 60)
                    Divider()
                        .background(Color.gray)
                        .position(x: 200, y:85)
                }
                ZStack {
//                    Button(action: {
//                        //                    showingFileImporter = true
//                        showingTypeSelection = true
//                    }) {
//                        Label("Import CSV", systemImage: "square.and.arrow.down")
//                            .font(.caption)
//                            .padding(5)
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .cornerRadius(5)
//                    }
//                    .position(x: 65, y: 65) // Move the button closer to the top-left corner
//                    .confirmationDialog("Select File Type", isPresented: $showingTypeSelection, titleVisibility: .visible) {
//                        Button("Verb") {
//                            selectedFileType = "verbs"
//                            showingFileImporter = true
//                        }
//                        Button("Sentence") {
//                            selectedFileType = "GerSentences"
//                            showingFileImporter = true
//                        }
//                        Button("Noun") {
//                            selectedFileType = "nouns"
//                            showingFileImporter = true
//                        }
//                        Button("Note") {
//                            selectedFileType = "note"
//                            showingFileImporter = true
//                        }
//                        Button("Cancel", role: .cancel) {}
//                    }
//                    .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
//                        do {
//                            let selectedFile = try result.get()
//                            let fileName = "\(selectedFileType).csv"  // Use the selected file type for the name
//                            
//                            // Check if the Resource folder exists or create it if necessary
//                            if let resourceFolderURL = Bundle.main.url(forResource: selectedFileType, withExtension: "csv") {
//                                // Check if the file exists at the given path
//                                if !FileManager.default.fileExists(atPath: resourceFolderURL.path) {
//                                    print("File does not exist at path: \(resourceFolderURL.path)")
//                                    return
//                                }
//                                
//                                // Overwrite the existing file at resourceFolderURL if it exists
//                                if FileManager.default.fileExists(atPath: resourceFolderURL.path) {
//                                    do {
//                                        try FileManager.default.removeItem(at: resourceFolderURL)
//                                        // Proceed with copying the new file
//                                    } catch {
//                                        print("Failed to remove the existing file: \(error)")
//                                    }
//                                }
//                                
//                                // Copy the new file to the Resource folder
//                                try FileManager.default.copyItem(at: selectedFile, to: resourceFolderURL)
//                                viewModel.loadCSV()
//                                print("\(fileName) imported successfully to Resource/ and overwritten!")
//                            } else {
//                                print("Resource folder URL is invalid.")
//                            }
//                        } catch {
//                            print("Failed to import file: \(error)")
//                        }
//                    }
                    
                    
                    if viewModel.failedAttempts >= 1 {
                        Button(action: {
                            showingHint = true
                        }) {
                            Label("Hint", systemImage: "lightbulb")
                                .padding(7)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .bold()
                            //                        .shadow(radius: 1)
                                .buttonStyle(.bordered)
                                .clipShape(Capsule())
                        }
                        .position(x: UIScreen.main.bounds.width - 50, y: 60)  //Position in top-right corner
                        //                    .frame(maxWidth: .infinity, alignment: .trailing)
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
    }
    
    
}

struct SentencePreviews: PreviewProvider {
    static var previews: some View {
        SentenceView()
    }
}
