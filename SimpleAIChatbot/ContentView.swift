//
//  ContentView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-08.
//

import SwiftUI

// Main content view that houses the tab navigation between the Chat and Archive views.
struct ContentView: View {
    // State variables to manage user input, the chatbot's response, loading state, and archived chat entries.
    @State private var userMessage: String = "" // Holds the user's input message.
    @State private var responseMessage: AttributedString = "" // Holds the chatbot's response in an attributed string format.
    @State private var isLoading: Bool = false // Boolean flag to indicate if a network request is in progress.
    @State private var chatEntries: [ChatEntry] = [] // Array to store archived chat entries.
    @State private var selectedModel: String = "llama3.1" // The selected model for generating responses, defaulting to "llama3.1".
    
    // Default values for chatbot customization
    @State private var temperature: Double = 0.8
    @State private var seed: Int = 42
    @State private var top_k: Int = 40
    
    // Instance of NetworkService to handle network requests.
    private let networkService = NetworkService()
    
    // Initializer to load any saved chat entries from UserDefaults upon view initialization.
    init() {
        self.chatEntries = loadChatEntriesFromUserDefaults()
    }

    // The main body of the ContentView, defining the TabView with Chat and Archive views.
    var body: some View {
        NavigationView {
            TabView {
                // ChatView for interacting with the chatbot.
                ChatView(
                    userMessage: $userMessage, // Binding the user input message.
                    responseMessage: $responseMessage, // Binding the chatbot's response message.
                    isLoading: $isLoading, // Binding the loading state.
                    selectedModel: $selectedModel,  // Binding the selected model for response generation.
                    fetchResponse: fetchResponse, temperature: $temperature,
                    seed: $seed,
                    top_k: $top_k // Passing the fetchResponse function to handle the chat interaction.
                )
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                
                // ArchiveView for displaying saved chat entries.
                ArchiveView(chatEntries: chatEntries)
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
            }
            .accentColor(.orange) // Setting the accent color for the tab view.
            
        }
    }
        
    // Function to fetch the chatbot's response from the selected model.
    func fetchResponse() {
        guard !userMessage.isEmpty else { return } // Ensure the user message is not empty.
        isLoading = true // Set loading state to true.
        responseMessage = "" // Clear previous response message.
        
        // Log the selected model to the console for debugging.
        print("Selected model: \(selectedModel)")
        print("Temperature: \(temperature)")
        print("Seed: \(seed)")
        print("Top K: \(top_k)")
        
        // Call the network service to fetch the response.
        networkService.fetchResponse(for: userMessage, model: selectedModel, temperature: temperature, seed: seed, top_k: top_k) { result in
            isLoading = false // Set loading state to false once the request is complete.
            switch result {
            case .success(let chatEntry): // If the request is successful.
                responseMessage = chatEntry.response // Update the response message.
                saveChatEntry(chatEntry: chatEntry) // Save the chat entry to the archive.
            case .failure(let error): // If the request fails.
                responseMessage = AttributedString("Error: \(error.localizedDescription)") // Display the error message.
            }
        }
    }
    
    // Function to save a chat entry to the chatEntries array and persist it using UserDefaults.
    func saveChatEntry(chatEntry: ChatEntry) {
        chatEntries.append(chatEntry) // Append the new chat entry to the array.
        saveChatEntriesToUserDefaults(chatEntries) // Persist the updated array using UserDefaults.
    }
    
    // Function to save chat entries to UserDefaults.
    func saveChatEntriesToUserDefaults(_ entries: [ChatEntry]) {
        do {
            let data = try JSONEncoder().encode(entries) // Encode the chat entries array into Data.
            UserDefaults.standard.set(data, forKey: "chatEntries") // Save the encoded data to UserDefaults.
        } catch {
            print("Failed to save chat entries: \(error)") // Log an error message if saving fails.
        }
    }
    
    // Function to load chat entries from UserDefaults.
    func loadChatEntriesFromUserDefaults() -> [ChatEntry] {
        if let data = UserDefaults.standard.data(forKey: "chatEntries") {
            do {
                let entries = try JSONDecoder().decode([ChatEntry].self, from: data) // Decode the data into an array of ChatEntry.
                return entries // Return the decoded array.
            } catch {
                print("Failed to load chat entries: \(error)") // Log an error message if loading fails.
            }
        }
        return [] // Return an empty array if no data is found.
    }
}

#Preview {
    ContentView() // Preview the ContentView in the SwiftUI canvas.
}

