//
//  NetworkService.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-15.
//

import Foundation

/// `NetworkService` is responsible for handling network requests to fetch chatbot responses.
struct NetworkService {
    
    /// Sends a POST request to the API to fetch the chatbot's response.
    /// - Parameters:
    ///   - userMessage: The message input from the user.
    ///   - model: The AI model to use (e.g., "llama3.1").
    ///   - temperature: A parameter that controls the creativity of the model's responses.
    ///   - seed: A random seed for deterministic outputs.
    ///   - top_k: A parameter controlling response diversity.
    ///   - completion: A closure to handle the result, returning either a `ChatEntry` or an `Error`.
    func fetchResponse(
        for userMessage: String,
        model: String,
        temperature: Double,
        seed: Int,
        top_k: Int,
        completion: @escaping (Result<ChatEntry, Error>) -> Void
    ) {
        // Validate user message.
        guard !userMessage.isEmpty else {
            completion(.failure(NetworkError.invalidInput("User message cannot be empty.")))
            return
        }
        
        // Construct the API URL.
        let baseURL = "http://localhost:11434"
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Configure the URL request.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the JSON body for the POST request.
        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": userMessage]
            ],
            "options": [
                "seed": seed,
                "temperature": temperature,
                "top_k": top_k
            ],
            "stream": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(NetworkError.invalidRequestBody))
            return
        }
        
        // Execute the network request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Handle any errors from the network layer.
                if let error = error {
                    completion(.failure(NetworkError.networkError(error.localizedDescription)))
                    return
                }
                
                // Ensure the server returned data.
                guard let data = data else {
                    completion(.failure(NetworkError.noDataReceived))
                    return
                }
                
                do {
                    // Decode the JSON response.
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let chatResponse = try decoder.decode(ChatResponse.self, from: data)
                    
                    // Process the decoded response.
                    if let message = chatResponse.message {
                        let chatEntry = ChatEntry(
                            question: userMessage,
                            responseMarkdown: message.content,
                            date: Date(),
                            modelName: model
                        )
                        completion(.success(chatEntry))
                    } else if let errorMessage = chatResponse.error {
                        completion(.failure(NetworkError.serverError(errorMessage)))
                    } else {
                        completion(.failure(NetworkError.unexpectedResponseFormat))
                    }
                } catch {
                    completion(.failure(NetworkError.failedToParseResponse(error.localizedDescription)))
                }
            }
        }.resume() // Start the network request.
    }
}

/// A struct for decoding the API's JSON response.
struct ChatResponse: Codable {
    let model: String
    let created_at: String
    let message: Message?
    let error: String?
    let done: Bool

    struct Message: Codable {
        let role: String
        let content: String
    }
}

/// An enum representing possible network errors.
enum NetworkError: Error, CustomStringConvertible {
    case invalidURL
    case invalidInput(String)
    case invalidRequestBody
    case noDataReceived
    case serverError(String)
    case unexpectedResponseFormat
    case networkError(String)
    case failedToParseResponse(String)
    
    /// A user-friendly description of each error case.
    var description: String {
        switch self {
        case .invalidURL:
            return "The URL is invalid. Please check your server configuration."
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .invalidRequestBody:
            return "Failed to encode the request body as JSON."
        case .noDataReceived:
            return "No data was received from the server."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unexpectedResponseFormat:
            return "Unexpected response format from the server."
        case .networkError(let message):
            return "Network error: \(message)"
        case .failedToParseResponse(let message):
            return "Failed to parse the server response: \(message)"
        }
    }
}
