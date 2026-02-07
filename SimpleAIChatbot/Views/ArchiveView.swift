//
//  ArchiveView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//

import SwiftUI

/// Displays archived chat entries with search and delete functionalities.
struct ArchiveView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var searchText = ""
    
    // State variables for delete confirmation and undo functionality
    @State private var showDeleteConfirmation = false
    @State private var entryToDelete: ChatEntry?
    
    @State private var recentlyDeletedEntry: ChatEntry?
    @State private var showUndoToast: Bool = false

    // Filters chat entries based on the search text, matching questions or responses.
    var filteredEntries: [ChatEntry] {
        let sortedEntries = viewModel.chatEntries.sorted { $0.date > $1.date }
        
        if searchText.isEmpty {
            return sortedEntries
        } else {
            return sortedEntries.filter {
                $0.question.lowercased().contains(searchText.lowercased()) ||
                $0.response.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background styling
                Color.white
                    .overlay(
                        Image("BackgroundPattern")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.2)
                    )
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    if filteredEntries.isEmpty {
                        // Placeholder for empty archive
                        VStack {
                            Image(systemName: "tray")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                            Text("No archived chats yet.")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ForEach(filteredEntries) { entry in
                            NavigationLink(destination: ChatDetailView(chatEntry: entry)) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(entry.question)
                                        .font(.headline)
                                    
                                    Text(entry.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    // Display AI response or error
                                    if let attributedResponse = try? AttributedString(markdown: entry.responseMarkdown) {
                                        Text(attributedResponse.description)
                                            .font(.body)
                                            .lineSpacing(2)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                    } else {
                                        Text("Error parsing response.")
                                            .font(.body)
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .frame(alignment: .leading)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: initiateDelete)
                    }
                }
                .listStyle(PlainListStyle()) // Use a plain list style for better transparency
                .scrollContentBackground(.hidden)
                
                // Undo Toast
                VStack {
                    Spacer()
                    if showUndoToast, recentlyDeletedEntry != nil {
                        HStack {
                            Text("Chat deleted")
                                .foregroundColor(.white)
                            Spacer()
                            Button("Undo") {
                                undoDelete()
                            }
                            .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding()
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showUndoToast)
                    }
                }
            }
            .navigationTitle("Archive")
            .navigationBarItems(trailing: EditButton())
            .searchable(text: $searchText)
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Chat Entry"),
                    message: Text("Are you sure you want to delete this chat entry?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let entry = entryToDelete {
                            withAnimation {
                                viewModel.delete(entry: entry)
                                recentlyDeletedEntry = entry
                                showUndoToast = true
                                
                                // Automatically hide the toast after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showUndoToast = false
                                        recentlyDeletedEntry = nil
                                    }
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // Marks an entry for deletion with confirmation
    private func initiateDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            entryToDelete = filteredEntries[index]
            showDeleteConfirmation = true
        }
    }
    
    // Re-adds a recently deleted entry
    private func undoDelete() {
        if let entry = recentlyDeletedEntry {
            withAnimation {
                viewModel.addChatEntry(entry) // Use ViewModel's add function
                recentlyDeletedEntry = nil
                showUndoToast = false
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
            .environmentObject(sampleViewModel)
    }
    
    static var sampleViewModel: ChatViewModel {
        let viewModel = ChatViewModel()
        viewModel.chatEntries = sampleChats
        return viewModel
    }
}
