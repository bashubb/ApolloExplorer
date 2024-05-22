//
//  ContentView.swift
//  ApolloExplorer
//
//  Created by HubertMac on 22/05/2024.
//

import SwiftUI

enum Tab {
    case learn
    case quiz
}

struct ContentView: View {
    var body: some View {
        TabView {
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "books.vertical")
                }
                .tag(Tab.learn)
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.square.dashed")
                }
                .tag(Tab.quiz)
        }
    }
}

#Preview {
    ContentView()
}
