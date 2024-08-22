//
//  ChatEntry.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//

import Foundation
import SwiftUI

/// Represents a single chat entry with user input and AI response.
struct ChatEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let question: String
    let responseMarkdown: String
    let date: Date
    let modelName: String
    
    /// Returns the AI's response as an `AttributedString` for rendering formatted text.
    var response: AttributedString {
        get {
            do {
                return try AttributedString(markdown: responseMarkdown)
            } catch {
                print("Failed to parse markdown for entry ID \(id): \(error)")
                return AttributedString("Error parsing response.")
            }
        }
    }
    
    /// Initializes a new `ChatEntry` instance.
    init(id: UUID = UUID(), question: String, responseMarkdown: String, date: Date, modelName: String) {
        self.id = id
        self.question = question
        self.responseMarkdown = responseMarkdown
        self.date = date
        self.modelName = modelName
    }
}

/// Sample chat entries for testing and demonstration.
let sampleChats: [ChatEntry] = [
    ChatEntry(
        question: "Why is the sky blue?",
        responseMarkdown: """
        The sky appears blue to us because of a phenomenon called Rayleigh scattering. 
        When sunlight enters Earth's atmosphere, it encounters tiny molecules of gases such as nitrogen (N2) and oxygen (O2). 
        These molecules scatter the light in all directions, but they scatter shorter (blue) wavelengths more than longer (red) wavelengths.
        """,
        date: Date(),
        modelName: "llama3.1"
    ),
    ChatEntry(
        question: "What is the speed of light?",
        responseMarkdown: """
        The speed of light in a vacuum is approximately 299,792 kilometers per second.
        """,
        date: Date().addingTimeInterval(-86400), // 1 day ago
        modelName: "llama3.2"
    ),
    ChatEntry(
        question: "How does gravity work?",
        responseMarkdown: """
        Gravity is the force that attracts two bodies toward each other. It is described by Isaac Newton's law of universal gravitation and Einstein's general theory of relativity.
        """,
        date: Date().addingTimeInterval(-172800), // 2 days ago
        modelName: "mistral"
    )
]
