//
//  ChatViewModel.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-11-13.
//

import SwiftUI
import Combine

/// `ChatViewModel` manages the state and logic for chat entries, including persistence and deletion.
class ChatViewModel: ObservableObject {
    // Published array of chat entries to notify views of updates
    @Published var chatEntries: [ChatEntry] = []
    
    // Initialize and load chat entries from persistent storage
    init() {
        loadChatEntries()
    }
    
    /// Adds a new chat entry to the list and saves the updated list.
    /// - Parameter entry: The `ChatEntry` object to add.
    func addChatEntry(_ entry: ChatEntry) {
        chatEntries.append(entry)
        saveChatEntries()
    }
    
    /// Deletes a specific chat entry and saves the updated list.
    /// - Parameter entry: The `ChatEntry` object to delete.
    func delete(entry: ChatEntry) {
        if let index = chatEntries.firstIndex(where: { $0.id == entry.id }) {
            chatEntries.remove(at: index)
            saveChatEntries()
        }
    }
    
    /// Deletes chat entries at the specified offsets and saves the updated list.
    /// - Parameter offsets: The offsets of the entries to delete.
    func delete(at offsets: IndexSet) {
        chatEntries.remove(atOffsets: offsets)
        saveChatEntries()
    }
    
    /// Saves the current list of chat entries to `UserDefaults`.
    /// Uses JSON encoding to serialize the data.
    private func saveChatEntries() {
        do {
            let data = try JSONEncoder().encode(chatEntries)
            UserDefaults.standard.set(data, forKey: "chatEntries")
        } catch {
            print("Error saving chat entries: \(error.localizedDescription)")
        }
    }
    
    /// Loads chat entries from `UserDefaults`.
    /// If decoding fails, clears corrupted data and resets the list.
    private func loadChatEntries() {
        guard let data = UserDefaults.standard.data(forKey: "chatEntries") else { return }
        do {
            let entries = try JSONDecoder().decode([ChatEntry].self, from: data)
            self.chatEntries = entries
        } catch {
            print("Error loading chat entries: \(error.localizedDescription)")
            // Clear corrupted data to prevent further issues
            UserDefaults.standard.removeObject(forKey: "chatEntries")
        }
    }
}
