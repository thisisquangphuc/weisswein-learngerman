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

    var body: some View {
        ZStack {
            Color(viewModel.getCustomBackGroundColor())
                .edgesIgnoringSafeArea([.top, .bottom, .leading, .trailing])
            
            ZStack {
                ZStack {
                 
                    VStack {
                        Text(viewModel.items[viewModel.currentIndex].fullWord)
                            .font(.title)
                            .bold()
                            .scaleEffect(viewModel.isCorrect ? 1.5 : 10)
                            .animation(.easeOut(duration: 0.4), value: viewModel.isCorrect)
                            .foregroundColor(viewModel.getCustomTextColor())
//                            .padding(.top, 20)
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
                            .modifier(Shake(animatableData: viewModel.shakeTrigger))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(10)
                            .foregroundColor(.black)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .shadow(radius: 3)
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
                } // Main Vstack
                .frame(maxHeight: .infinity, alignment: .center)

                Spacer()
            }
            .padding()
            

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
    
    private func callEffects() {
        if viewModel.isCorrect == true {
            congratsTrigger += 1
        }
    }
}

struct NounPreviews: PreviewProvider {
    static var previews: some View {
        NounView()
    }
}
