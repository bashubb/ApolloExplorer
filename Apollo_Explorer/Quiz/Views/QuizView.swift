//
//  QuizView.swift
//  ApolloExplorer
//
//  Created by HubertMac on 22/05/2024.
//

import SwiftUI

struct QuizView: View {
    @StateObject var vm = ViewModel()
   
    
    var body: some View {
        NavigationStack {
            List {
                Spacer().listRowBackground(Color.clear)
                
                Section("Select some options before start 🚀") {
                    Picker("Choose number of questions", selection: $vm.choosenQustionNumber) {
                        ForEach(vm.questionsNumberOptions, id: \.self) { option in
                            Text("\(option)").tag(option.self)
                        }
                    }
                    .listRowBackground(Color.lightBackground)
                    .padding(.vertical)
                    Picker("Choose difficulty", selection: $vm.choosenDifficulty) {
                        ForEach(QuestionDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty.self)
                        }
                    }
                    .listRowBackground(Color.lightBackground)
                    .padding(.vertical)
                }
                
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: QuestionView(
                            choosenQustionNumber: vm.choosenQustionNumber,
                            difficulty: vm.choosenDifficulty
                        )
                    ) {
                       Text("Let's play")
                            .padding()
                    }
                    
                    
                    
                    Spacer()
                }
                .listRowBackground(Color.blue)

            }
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .background(.darkBackground)
            .navigationTitle("Apollo Quiz")
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    QuizView()
}
