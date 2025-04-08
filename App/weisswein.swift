//
//  weisswein.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {

        TabView {
            SentenceView()
                .tabItem { Text("Sentences") }
            NounView()
                .tabItem { Text("Nouns") }
            VerbsView()
                .tabItem { Text("Verb") }
            SentencePuzzleView()
                .tabItem { Text("Learn") }
        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .ignoresSafeArea(.all)  // Add this
        .onAppear {
            // Set tab bar to be transparent when TabView loads
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().isTranslucent = true
            UITabBar.appearance().backgroundColor = .clear
        }

    }
}

@main
struct DailyReviewApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
