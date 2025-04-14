//
//  Untitled.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//
import SwiftUI


struct NounView: View {
    @StateObject var viewModel = NounViewModel()
    @State private var showingHint = false
    
    @State private var congratsTrigger: Int=0
    @State private var hintImageURL: URL?
    @State private var showingImageHint = false
    
    @State private var showingSettings = false
    @State  var shakeTrigger: CGFloat = 0
    var body: some View {
        ZStack {
//            Color(viewModel.getCustomBackGroundColor())
//                .edgesIgnoringSafeArea([.top, .bottom, .leading, .trailing])
            
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
            
            ZStack {
                ZStack {
                 
                    VStack {
                        Text(viewModel.items[viewModel.currentIndex].fullWord)
                            .font(.title)
                            .bold()
//                            .scaleEffect(viewModel.isCorrect ? 1.5 : 10)
                            .animation(.easeOut(duration: 0.4), value: viewModel.isCorrect)
                            .foregroundColor(viewModel.getCustomTextColor())
                            .confettiCannon(trigger: $congratsTrigger, num: 100, colors: viewModel.getConfettiColors(), confettiSize: 7, rainHeight:300, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 180), radius: 500)
                        if viewModel.items[viewModel.currentIndex].plural != "" {
                            Text("die " + viewModel.items[viewModel.currentIndex].plural)
                                .font(.system(size: 30))
    //                                        .scaleEffect(viewModel.isCorrect ? 1.5 : 5)
    //                                        .animation(.easeIn(duration: 0.5), value: viewModel.isCorrect)
                                .foregroundColor(viewModel.getCustomTextColor())
//                                .padding()
                        }
                        if viewModel.isCorrect {
                            Divider()
                                .background(Color.gray)
                        }
                    } // Full word - Plural
//                    Spacer()
//                .edgesIgnoringSafeArea(.top)
                .padding(.top, 200)
                .frame(maxHeight: .infinity, alignment: .top)
                    VStack {
                        Text(viewModel.items.isEmpty ? "Loading..." : viewModel.items[viewModel.currentIndex].meaning)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        VStack {
                            TextField("Enter the correct noun", text: $viewModel.userInput, onCommit: {
                                viewModel.isCorrect = viewModel.checkAnswer()
                                callEffects()
                            })
                            .modifier(Shake(animatableData: shakeTrigger))
                        }
                        .padding(10)
                        .foregroundColor(.black)
                        .textInputAutocapitalization(.never)
                        .background(Color(hex: "F5F5F5")) //CHatGPT IOS app color
                        .disableAutocorrection(true)
                        .cornerRadius(30)
                        
                        Button(action: {
                            viewModel.nextNoun()
                            viewModel.isCorrect = false
                        }) {
                            Label("Next", systemImage: "arrow.right.circle.fill")
                            
                        }
                        .font(.system(size:20))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color(hex: "F5F5F5"))
                        .foregroundColor(.black)
                        .clipShape(Capsule())

                    }
                } // Main Vstack
                .frame(maxHeight: .infinity, alignment: .center)

                Spacer()
            }
            .padding()
            
            if viewModel.failedAttempts >= 1 {
                Button(action: {
                    showingHint = true
                    let word = viewModel.items[viewModel.currentIndex].singWord
                    fetchHintImage(for: word)
                }) {
                    Image(systemName: "lightbulb.fill")
                        .padding(10)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .position(x: UIScreen.main.bounds.width - 50, y: 12)
            }
        }
        .sheet(isPresented: $showingImageHint) {
            VStack {
                if let url = hintImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                        case .failure(_):
                            Text("Failed to load image.")
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text("No image found.")
                }
                Button("Close") {
                    showingImageHint = false
                }
                .padding()
            }
            .padding()
        }
    }
    
    private func callEffects() {
        if viewModel.isCorrect == true {
            congratsTrigger += 1
        } else {
            
        }
    }
    
    private func fetchHintImage(for word: String) {
        let searchWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? word
        guard let url = URL(string: "https://www.verbformen.de/?w=\(searchWord)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                return
            }

            // Search for JSON-like image URL info from HTML
            if let imageTypeRange = html.range(of: #"\"@type\"\s*:\s*\"ImageObject\""#, options: .regularExpression),
               let urlKeyRange = html.range(
                   of: #"\"url\"\s*:\s*\"https:\/\/www\.verbformen\.de.*?\.png""#,
                   options: .regularExpression,
                   range: imageTypeRange.upperBound..<html.endIndex
               ) {

                let urlLine = html[urlKeyRange]
                let cleanedURL = urlLine
                    .replacingOccurrences(of: "\"url\":", with: "")
                    .replacingOccurrences(of: "\"", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if let finalURL = URL(string: cleanedURL) {
                    DispatchQueue.main.async {
                        self.hintImageURL = finalURL
                        self.showingImageHint = true
                    }
                }
            } else {
                // Fallback in case no image is found
                DispatchQueue.main.async {
                    self.hintImageURL = nil
                    self.showingImageHint = true
                }
            }
        }.resume()
    }
}

struct NounPreviews: PreviewProvider {
    static var previews: some View {
        NounView()
    }
}
