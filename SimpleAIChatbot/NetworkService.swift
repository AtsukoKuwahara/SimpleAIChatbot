//
//  NetworkService.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-15.
//

import Foundation
import SwiftUI

// NetworkService is responsible for handling network requests to fetch chatbot responses.
struct NetworkService {
    
    // This function sends a POST request to the API to fetch the chatbot's response.
    // It takes the user's message, the selected model, and a completion handler as parameters.
    func fetchResponse(for userMessage: String, model: String, completion: @escaping (Result<ChatEntry, Error>) -> Void) {
        guard !userMessage.isEmpty else { return } // Ensure the user message is not empty before proceeding.

        // Construct the URL for the API request.
        let url = URL(string: "http://localhost:11434/api/chat")! // Ollama API URL (ensure the server is running).
        var request = URLRequest(url: url) // Create a URLRequest with the URL.
        request.httpMethod = "POST" // Set the HTTP method to POST.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set the request header to indicate JSON content.

        // Prepare the body of the POST request as a JSON object.
        let body: [String: Any] = [
            "model": model, // Include the selected model in the request.
            "messages": [
                ["role": "user", "content": userMessage] // Include the user's message in the request.
            ],
            "stream": false // Disable streaming to receive the full response at once.
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body) // Convert the body to JSON data.

        // Perform the network request using URLSession.
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Handle any errors encountered during the request.
                if let error = error {
                    completion(.failure(error)) // Pass the error to the completion handler.
                    return
                }

                // Ensure that data was received from the server.
                guard let data = data else {
                    completion(.failure(NetworkError.noDataReceived)) // Handle case where no data was received.
                    return
                }

                do {
                    // Attempt to parse the JSON response from the server.
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Extract the content from the response.
                        if let message = jsonResponse["message"] as? [String: Any],
                           let content = message["content"] as? String {
                            // Create a new ChatEntry with the received content and selected model.
                            let chatEntry = ChatEntry(question: userMessage, responseMarkdown: content, date: Date(), modelName: model)
                            completion(.success(chatEntry)) // Pass the ChatEntry to the completion handler.
                        } else if let errorMessage = jsonResponse["error"] as? String {
                            // Handle any error messages returned by the server.
                            let error = NetworkError.serverError(errorMessage)
                            completion(.failure(error))
                        } else {
                            // Handle unexpected response formats.
                            completion(.failure(NetworkError.unexpectedResponseFormat))
                        }
                    }
                } catch {
                    // Handle any errors encountered while parsing the JSON.
                    completion(.failure(NetworkError.failedToParseResponse))
                }
            }
        }.resume() // Start the network request.
    }
}

// Enum to define possible network errors for better error handling.
enum NetworkError: Error {
    case noDataReceived // No data was received from the server.
    case serverError(String) // The server returned an error message.
    case unexpectedResponseFormat // The response format was not as expected.
    case failedToParseResponse // Failed to parse the JSON response.
}

