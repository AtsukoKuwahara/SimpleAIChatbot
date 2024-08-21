//
//  ArchiveView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//

import SwiftUI

struct ArchiveView: View {
    @State private var searchText = ""
    var chatEntries: [ChatEntry]

    var filteredEntries: [ChatEntry] {
        if searchText.isEmpty {
            return chatEntries
        } else {
            return chatEntries.filter {
                $0.question.lowercased().contains(searchText.lowercased()) ||
                $0.response.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                
                Color.white
                    .overlay(
                        Image("IMG_1576") // background image
                            .resizable()
                            .scaledToFill()
                            .opacity(0.2)
                    )
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    ForEach(filteredEntries) { entry in
                        NavigationLink(destination: ChatDetailView(chatEntry: entry)) {
                            VStack(alignment: .leading) {
                                Text(entry.question)
                                    .font(.headline)
                                Text(entry.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(try! AttributedString(markdown: entry.responseMarkdown)
                                            .description.prefix(80) + "...")
                                        .font(.body)
                                        .lineSpacing(4)
                                        .padding(.top, 5)
                                        .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemGroupedBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding(1)
                .padding(.bottom, 20)
            }
            .navigationTitle("Archive")
            .searchable(text: $searchText)
        }
        
    }
}

struct CustomTitleView: View {
    var body: some View {
        Text("Archive")
            .font(.custom("Courier-Bold", size: 36))
            .foregroundColor(.orange)
            .padding(.vertical, 10)
    }
}

#Preview {
    ArchiveView(chatEntries: sampleChats)
}
