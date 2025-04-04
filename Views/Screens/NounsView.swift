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

    var body: some View {
        ZStack {
            Color(viewModel.getCustomBackGroundColor())
                .edgesIgnoringSafeArea([.top, .bottom, .leading, .trailing])
            
            ZStack {
                
                VStack {
                    HStack {
                        
                        
                        if viewModel.isCorrect {
                            FireworkView()
                                .frame(width: 10, height: 10)
                                .opacity(viewModel.showFirework ? 1 : 0)
                                .padding(.top, 40)
                            
                            VStack {
                                Text(viewModel.items[viewModel.currentIndex].fullWord)
                                    .font(.title)
                                    .scaleEffect(viewModel.isCorrect ? 1.5 : 10)
                                    .animation(.easeOut(duration: 0.5), value: viewModel.isCorrect)
                                    .foregroundColor(viewModel.getCustomTextColor())
                                    .padding(.top, 20)
                                if viewModel.items[viewModel.currentIndex].plural != "" {
                                    Text("die " + viewModel.items[viewModel.currentIndex].plural)
                                        .font(.caption)
                                        .scaleEffect(viewModel.isCorrect ? 1.5 : 5)
                                        .animation(.easeIn(duration: 0.5), value: viewModel.isCorrect)
                                        .foregroundColor(.white)
                                        .padding()
                                }
                            }
                            
                            FireworkView()
                                .frame(width: 10, height: 10)
                                .opacity(viewModel.showFirework ? 1 : 0)
                                .padding(.top, 40)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .frame(maxHeight: .infinity, alignment: .top)
                
                Spacer()
                
                VStack {
                    Text(viewModel.items.isEmpty ? "Loading..." : viewModel.items[viewModel.currentIndex].meaning)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)

                    VStack {
                        TextField("Enter the correct noun", text: $viewModel.userInput, onCommit: {
                            viewModel.isCorrect = viewModel.checkAnswer()
                        })
                        .modifier(Shake(animatableData: viewModel.shakeTrigger))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                        .foregroundColor(.black)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
//                        .modifier(Shake(animatableData: CGFloat(attempts)))
                        
                    }
                    
                    Button("Next") {
                        viewModel.nextNoun()
                        viewModel.isCorrect = false
                    }
                    .padding(10)
                    .background(Color(hex: "#110AFF"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
              
                    
                }
                .frame(maxHeight: .infinity, alignment: .center)

                Spacer()
            }
            .padding()

            if viewModel.failedAttempts >= 1 {
                Button(action: {
                    showingHint = true
                }) {
                    Text("Hint")
                        .font(.caption)
                        .padding(5)
                        .background(Color(hex: "#FF230A"))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .position(x: UIScreen.main.bounds.width - 50, y: 30)
                .alert(isPresented: $showingHint) {
                    Alert(
                        title: Text("Hint"),
                        message: Text(viewModel.items[viewModel.currentIndex].fullWord),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

