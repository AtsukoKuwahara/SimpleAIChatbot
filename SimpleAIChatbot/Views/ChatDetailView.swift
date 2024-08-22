//
//  ChatDetailView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//


import SwiftUI

/// Displays details of a single chat entry, including the question, date, model, and response.
struct ChatDetailView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    var chatEntry: ChatEntry

    var body: some View {
        ZStack {
            Color.white
                .overlay(
                    Image("BackgroundPattern")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.2)
                )
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 10) {
                // Question text
                Text(chatEntry.question)
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.leading,10)

                // Date and model details
                VStack(alignment: .leading, spacing: 5) {
                    Text(chatEntry.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Model used: \(chatEntry.modelName)")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(.leading,10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(chatEntry.response)
                            .font(.system(size: 18))
                            .lineSpacing(5)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                }

            }
            .padding()
//            .navigationTitle("Chat Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatDetailView(chatEntry: sampleChats[0])
}
