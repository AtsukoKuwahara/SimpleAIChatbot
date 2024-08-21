//
//  ChatModel.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//

import Foundation
import SwiftUI

struct ChatEntry: Identifiable, Codable {
    let id: UUID
    let question: String
    let responseMarkdown: String
    let date: Date
    let modelName: String
    
    var response: AttributedString {
        get {
            return try! AttributedString(markdown: responseMarkdown)
        }
    }
    
    init(id: UUID = UUID(), question: String, responseMarkdown: String, date: Date, modelName: String) {
        self.id = id
        self.question = question
        self.responseMarkdown = responseMarkdown
        self.date = date
        self.modelName = modelName
    }
}


let sampleChats: [ChatEntry] = [
    ChatEntry(question: "Why is the sky blue?", responseMarkdown: "The sky appears blue to us because of a phenomenon called Rayleigh scattering. When sunlight enters Earth's atmosphere, it encounters tiny molecules of gases such as nitrogen (N2) and oxygen (O2). These molecules scatter the light in all directions, but they scatter shorter (blue) wavelengths more than longer (red) wavelengths. This is known as Rayleigh scattering.", date: Date(), modelName: "llama3.1"),
    ChatEntry(question: "What is the speed of light?", responseMarkdown: "The speed of light in a vacuum is approximately 299,792 kilometers per second.", date: Date().addingTimeInterval(-86400), modelName: "llama3"),
    ChatEntry(question: "How does gravity work?", responseMarkdown: "Gravity is the force that attracts two bodies toward each other.", date: Date().addingTimeInterval(-172800), modelName: "mistral")
]
