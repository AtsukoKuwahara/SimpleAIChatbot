//
//  ContentView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-08.
//

import SwiftUI

/// Main content view that houses the tab navigation between Chat and Archive views.
struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel() // ViewModel to manage chat data and logic
        
        // State variables to manage user input, chatbot response, loading state, and model selection
        @State private var userMessage: String = ""             // Holds the user's input message
        @State private var responseMessage: AttributedString = "" // Holds the chatbot's response as an attributed string
        @State private var isLoading: Bool = false              // Tracks if a network request is in progress
        @State private var selectedModel: String = "llama3.1"   // Default model for generating responses
        
        // Parameters for customizing chatbot behavior
        @State private var temperature: Double = 0.8
        @State private var seed: Int = 42
        @State private var top_k: Int = 40
        
        // Service for handling network requests
        private let networkService = NetworkService()

    var body: some View {
        NavigationView {
            TabView {
                // ChatView for interacting with the chatbot
                ChatView(
                    userMessage: $userMessage,
                    responseMessage: $responseMessage,
                    isLoading: $isLoading,
                    selectedModel: $selectedModel,
                    fetchResponse: fetchResponse,
                    temperature: $temperature,
                    seed: $seed,
                    top_k: $top_k
                )
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                
                // ArchiveView for displaying saved chat entries.
                ArchiveView()
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
            }
            .accentColor(.orange) // Set the accent color for the tab view.
        }
        .environmentObject(viewModel) // Inject the ViewModel into the environment
    }
        
    /// Function to fetch the chatbot's response from the selected model.
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
            DispatchQueue.main.async {
                isLoading = false // Set loading state to false once the request is complete.
                switch result {
                case .success(let chatEntry): // If the request is successful.
                    responseMessage = chatEntry.response // Update the response message.
                    viewModel.addChatEntry(chatEntry) // Save the chat entry to the archive via ViewModel.
                case .failure(let error): // If the request fails.
                    responseMessage = AttributedString("Error: \(error.localizedDescription)") // Display the error message.
                }
            }
        }
    }
}

#Preview {
    ContentView() // Preview the ContentView in the SwiftUI canvas.
}
