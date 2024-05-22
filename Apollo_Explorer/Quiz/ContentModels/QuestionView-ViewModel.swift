//
//  QuestionView-ViewModel.swift
//  ApolloExplorer
//
//  Created by HubertMac on 22/05/2024.
//

import Foundation

extension QuestionView {
    class ViewModel: ObservableObject {
        @Published var questions = [Question]()
        @Published var currentQuestion = 0
        @Published var showFinalAlert = false
        @Published var score = 0
        @Published var progress:Float = 1.0
        
        var quizData: [Question] = Bundle.main.decode("quiz.json")
        
        init(choosenQustionNumber: Int, difficulty: String) {
            self.questions = prepareQuestions(difficulty: difficulty, choosenQustionNumber: choosenQustionNumber)
        }
        
        func checkAnswer(_ userAnswer: String) -> Bool {
            if userAnswer == questions[currentQuestion].answer {
                score += 1
                return true
            } else {
                return false
            }
        }
        
        func prepareQuestions(difficulty: String, choosenQustionNumber: Int) -> [Question] {
            var preparedQuestions = [Question]()
            var filtered = [Question]()
            if difficulty != "Mix" {
                filtered = quizData.filter{ $0.difficulty == difficulty }.shuffled()
            } else {
                filtered = quizData.shuffled()
            }
            
            for i in 0..<choosenQustionNumber {
                preparedQuestions.append(filtered[i])
            }
            return preparedQuestions
        }
    
        func getProgress() {
            progress = 1 - Float(currentQuestion + 1) / Float(questions.count)
        }
        
        
        func nextQuestion() {
            if currentQuestion + 1 < questions.count {
                currentQuestion += 1
            } else {
                showFinalAlert = true
            }
        }
        
        func resetTheGame() {
            currentQuestion = 0
            score = 0
            progress = 1.0
        }
    }

    
}
