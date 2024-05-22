//
//  QuestionView.swift
//  ApolloExplorer
//
//  Created by HubertMac on 22/05/2024.
//

import SwiftUI

struct QuestionView: View {
    @StateObject var vm: ViewModel
    
    @State var userGotRight = false
    @State var userAnswered = false
    @State var optionTapped = ""
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            VStack(spacing: 30) {
                ProgressView(value: vm.progress, total: 1.0)
                questionText
                    .layoutPriority(1)
                
                VStack {
                    questionList
                        .transition(.asymmetric(insertion: .slide, removal: .scale))
                }
            }
            .animation(.default, value: vm.currentQuestion)
            .padding()
        }
        .onAppear(perform: vm.getProgress)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Score: \(vm.score)")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .alert("End of the game", isPresented: $vm.showFinalAlert) {
            Button("Play Again") {
                vm.resetTheGame()
            }
        } message: {
            Text("You've got \(vm.score) / \(vm.questions.count) points! ")
        }

    }
    
    init(choosenQustionNumber: Int, difficulty: String) {
        let viewModel = ViewModel(
            choosenQustionNumber: choosenQustionNumber,
            difficulty: difficulty
        )
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    /// Components
    
    var questionText: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(minHeight: 100,maxHeight: 150)
            .padding(2)
            .overlay {
                Text(vm.questions[vm.currentQuestion].question)
                    .padding()
                    .font(.title2)
                    .foregroundStyle(.white)
            }
    }
    
    @ViewBuilder
    var questionList: some View {
        let options = vm.questions[vm.currentQuestion].options
        
        ForEach(options, id: \.self) { option in
            Button {
                userGotRight = vm.checkAnswer(option)
                optionTapped = option
                withAnimation(.bouncy(duration: 2)){
                    userAnswered = true
                } completion: {
                    vm.nextQuestion()
                    userAnswered = false
                }
                vm.getProgress()
                
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(getButtonColor(option))
                    .frame(minHeight: 60, maxHeight: 90)
                    .padding(2)
                    .overlay {
                        Text(option)
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
            }
        }
    }
    
    func getButtonColor(_ option: String) -> Color {
        if userAnswered && option == optionTapped  {
            if userGotRight {
                Color.green
            } else {
                Color.red
            }
        } else if userAnswered && option != optionTapped && option == vm.questions[vm.currentQuestion].answer{
            Color.green
        } else {
            Color.lightBackground
        }
    }
}

#Preview {
    NavigationStack {
        QuestionView(choosenQustionNumber: 5, difficulty: "Medium")
    }
}
