//
//  ContentView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-08.
//

import SwiftUI

/// Main content view that houses the tab navigation between Chat and Archive views.
struct ContentView: View {
    private enum Tab: Hashable {
        case chat
        case archive
    }

    @StateObject private var viewModel = ChatViewModel()

    @State private var userMessage: String = ""
    @State private var responseMessage: AttributedString = ""
    @State private var isLoading: Bool = false
    @State private var selectedTab: Tab = .chat
    @State private var availableModels: [String] = ["llama3.1", "llama3.2", "mistral"]

    // Persisted settings for reproducible chat behavior across launches.
    @AppStorage("selectedModel") private var selectedModel: String = "llama3.1"
    @AppStorage("temperature") private var temperature: Double = 0.8
    @AppStorage("seed") private var seed: Int = 42
    @AppStorage("top_k") private var top_k: Int = 40

    private let networkService = NetworkService()
    // Prefixes for local models that should not appear in chat model choices.
    private let hiddenModelPrefixes: [String] = ["grooveguru", "codellama"]

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ChatView(
                    userMessage: $userMessage,
                    responseMessage: $responseMessage,
                    isLoading: $isLoading,
                    selectedModel: $selectedModel,
                    availableModels: $availableModels,
                    fetchResponse: fetchResponse,
                    refreshModels: refreshModels,
                    addModel: addModel,
                    temperature: $temperature,
                    seed: $seed,
                    top_k: $top_k
                )
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(Tab.chat)

                ArchiveView()
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tag(Tab.archive)
            }
            .accentColor(.orange)
        }
        .environmentObject(viewModel)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .archive {
                clearChatScreen()
            }
        }
        .onAppear {
            refreshModels { _ in }
        }
    }

    func fetchResponse() {
        guard !userMessage.isEmpty else { return }
        isLoading = true
        responseMessage = ""

        networkService.fetchResponse(
            for: userMessage,
            model: selectedModel,
            temperature: temperature,
            seed: seed,
            top_k: top_k
        ) { result in
            isLoading = false

            switch result {
            case .success(let chatEntry):
                responseMessage = chatEntry.response
                viewModel.addChatEntry(chatEntry)
            case .failure(let error):
                responseMessage = AttributedString("Error: \(error.localizedDescription)")
            }
        }
    }

    private func clearChatScreen() {
        userMessage = ""
        responseMessage = AttributedString("")
        isLoading = false
    }

    private func refreshModels(completion: @escaping (Result<[String], Error>) -> Void) {
        networkService.fetchAvailableModels { result in
            switch result {
            case .success(let models):
                let filteredModels = sanitizeModels(models)
                if !filteredModels.isEmpty {
                    availableModels = filteredModels
                    if !filteredModels.contains(selectedModel) {
                        selectedModel = filteredModels[0]
                    }
                }
                completion(.success(availableModels))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func addModel(named modelName: String, completion: @escaping (Result<[String], Error>) -> Void) {
        networkService.pullModel(named: modelName) { pullResult in
            switch pullResult {
            case .success:
                refreshModels { refreshResult in
                    switch refreshResult {
                    case .success(let models):
                        completion(.success(models))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func sanitizeModels(_ models: [String]) -> [String] {
        models.filter { model in
            let lowercased = model.lowercased()
            return !hiddenModelPrefixes.contains(where: { lowercased.hasPrefix($0) })
        }
    }
}

#Preview {
    ContentView()
}
