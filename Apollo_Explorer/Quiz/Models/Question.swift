//
//  Question.swift
//  ApolloExplorer
//
//  Created by HubertMac on 22/05/2024.
//

import Foundation

struct Question: Codable, Identifiable {
    var id: Int
    var question: String
    var options: [String]
    var answer: String
    var difficulty: String
}
