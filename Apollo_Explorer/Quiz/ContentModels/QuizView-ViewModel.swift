//
//  QuizView-ViewModel.swift
//  ApolloExplorer
//
//  Created by HubertMac on 22/05/2024.
//

import Foundation

extension QuizView {
    
    class ViewModel: ObservableObject {
        
        @Published var choosenQustionNumber = 5
        @Published var choosenDifficulty = "Easy"
        @Published var questionsNumberOptions = [5, 10, 20, 30]
    }
}
