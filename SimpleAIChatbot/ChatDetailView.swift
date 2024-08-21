//
//  ChatDetailView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//

import SwiftUI

struct ChatDetailView: View {
    var chatEntry: ChatEntry

    var body: some View {
        ZStack {
            Color.white
                .overlay(
                    Image("IMG_1576")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.2)
                )
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Text(chatEntry.question)
                    .font(.largeTitle)
                    .padding(.bottom, 10)

                Text(chatEntry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                Text("Model used: \(chatEntry.modelName)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(chatEntry.response)  // Use response property here
                            .font(.system(size: 18))
                            .lineSpacing(4)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                }

            }
            .padding()
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatDetailView(chatEntry: sampleChats[0])
}
