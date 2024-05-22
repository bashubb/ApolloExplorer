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
        
        // Buggy, needs some love
        func prepareQuestions(difficulty: String, choosenQustionNumber: Int) -> [Question] {
            var preparedQuestions = [Question]()
            var filtered = [Question]()
            if difficulty != "Mix" {
                filtered = quizData.filter{ $0.difficulty == difficulty }
            } else {
                filtered = quizData
            }
            
            for _ in 0..<choosenQustionNumber {
                let randomQuestion = filtered[Int.random(in: 0..<filtered.count)]
                preparedQuestions.append(randomQuestion)
            }
            return preparedQuestions
        }
    
        func getProgress() -> Float {
            Float(currentQuestion + 1) / Float(questions.count)
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
        }
    }

    
}
