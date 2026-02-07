//
//  NetworkService.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-15.
//

import Foundation

/// `NetworkService` handles network requests to fetch chatbot responses from Ollama.
struct NetworkService {
    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL = URL(string: "http://localhost:11434")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Sends a POST request to fetch the chatbot response.
    func fetchResponse(
        for userMessage: String,
        model: String,
        temperature: Double,
        seed: Int,
        top_k: Int,
        completion: @escaping (Result<ChatEntry, Error>) -> Void
    ) {
        let request: URLRequest

        do {
            request = try makeRequest(
                userMessage: userMessage,
                model: model,
                temperature: temperature,
                seed: seed,
                top_k: top_k
            )
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        session.dataTask(with: request) { data, response, error in
            let result: Result<ChatEntry, Error>

            if let error = error as? URLError {
                switch error.code {
                case .timedOut:
                    result = .failure(NetworkError.networkError("The request timed out. Check if Ollama is running."))
                case .cannotConnectToHost, .cannotFindHost, .notConnectedToInternet:
                    result = .failure(NetworkError.networkError("Cannot connect to Ollama server at \(self.baseURL.absoluteString)."))
                default:
                    result = .failure(NetworkError.networkError(error.localizedDescription))
                }
            } else if let error = error {
                result = .failure(NetworkError.networkError(error.localizedDescription))
            } else if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    let serverMessage = self.extractServerError(from: data)
                    result = .failure(NetworkError.serverError("HTTP \(httpResponse.statusCode): \(serverMessage)"))
                } else if let data {
                    do {
                        let entry = try self.decodeChatEntry(from: data, userMessage: userMessage, model: model)
                        result = .success(entry)
                    } catch {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(NetworkError.noDataReceived)
                }
            } else {
                result = .failure(NetworkError.invalidServerResponse)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    func fetchAvailableModels(completion: @escaping (Result<[String], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/tags")
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "GET"

        session.dataTask(with: request) { data, response, error in
            let result: Result<[String], Error>

            if let error {
                result = .failure(NetworkError.networkError(error.localizedDescription))
            } else if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    let message = self.extractServerError(from: data)
                    result = .failure(NetworkError.serverError("HTTP \(httpResponse.statusCode): \(message)"))
                    DispatchQueue.main.async { completion(result) }
                    return
                }

                guard let data else {
                    result = .failure(NetworkError.noDataReceived)
                    DispatchQueue.main.async { completion(result) }
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(ModelTagsResponse.self, from: data)
                    let names = decoded.models.map(\.name).sorted()
                    result = .success(names)
                } catch {
                    result = .failure(NetworkError.failedToParseResponse(error.localizedDescription))
                }
            } else {
                result = .failure(NetworkError.invalidServerResponse)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    func pullModel(named name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidInput("Model name cannot be empty.")))
            }
            return
        }
        let normalizedName = normalizeModelName(trimmedName)

        let url = baseURL.appendingPathComponent("api/pull")
        var request = URLRequest(url: url, timeoutInterval: 600)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": normalizedName,
            "stream": false
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequestBody))
            }
            return
        }

        session.dataTask(with: request) { data, response, error in
            let result: Result<Void, Error>

            if let error {
                result = .failure(NetworkError.networkError(error.localizedDescription))
            } else if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    result = .success(())
                } else {
                    let message = self.extractServerError(from: data)
                    result = .failure(NetworkError.serverError("HTTP \(httpResponse.statusCode): \(message)"))
                }
            } else {
                result = .failure(NetworkError.invalidServerResponse)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    private func normalizeModelName(_ name: String) -> String {
        if name.contains(":") { return name }
        return "\(name):latest"
    }

    func makeRequest(
        userMessage: String,
        model: String,
        temperature: Double,
        seed: Int,
        top_k: Int
    ) throws -> URLRequest {
        let trimmedMessage = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            throw NetworkError.invalidInput("User message cannot be empty.")
        }

        let url = baseURL.appendingPathComponent("api/chat")
        // Large local models can take longer on cold start.
        var request = URLRequest(url: url, timeoutInterval: 90)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ChatRequest(
            model: model,
            messages: [.init(role: "user", content: trimmedMessage)],
            options: .init(seed: seed, temperature: temperature, top_k: top_k),
            stream: false
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
            return request
        } catch {
            throw NetworkError.invalidRequestBody
        }
    }

    func decodeChatEntry(from data: Data, userMessage: String, model: String) throws -> ChatEntry {
        do {
            let response = try JSONDecoder().decode(ChatResponse.self, from: data)

            if let errorMessage = response.error {
                throw NetworkError.serverError(errorMessage)
            }

            guard let content = response.message?.content,
                  !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw NetworkError.unexpectedResponseFormat
            }

            return ChatEntry(
                question: userMessage,
                responseMarkdown: content,
                date: Date(),
                modelName: model
            )
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.failedToParseResponse(error.localizedDescription)
        }
    }

    private func extractServerError(from data: Data?) -> String {
        guard let data else {
            return "Server returned an error with empty response body."
        }

        if let parsed = try? JSONDecoder().decode(ChatResponse.self, from: data),
           let error = parsed.error,
           !error.isEmpty {
            return error
        }

        if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
            return raw
        }

        return "Unknown server error"
    }
}

struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
    let options: Options
    let stream: Bool

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct Options: Codable {
        let seed: Int
        let temperature: Double
        let top_k: Int
    }
}

struct ChatResponse: Codable {
    let model: String?
    let created_at: String?
    let message: Message?
    let error: String?
    let done: Bool?

    struct Message: Codable {
        let role: String
        let content: String
    }
}

struct ModelTagsResponse: Codable {
    let models: [ModelTag]

    struct ModelTag: Codable {
        let name: String
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidInput(String)
    case invalidRequestBody
    case noDataReceived
    case serverError(String)
    case invalidServerResponse
    case unexpectedResponseFormat
    case networkError(String)
    case failedToParseResponse(String)

    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .invalidRequestBody:
            return "Failed to encode the request body as JSON."
        case .noDataReceived:
            return "No data was received from the server."
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidServerResponse:
            return "Invalid response from the server."
        case .unexpectedResponseFormat:
            return "Unexpected response format from the server."
        case .networkError(let message):
            return "Network error: \(message)"
        case .failedToParseResponse(let message):
            return "Failed to parse the server response: \(message)"
        }
    }
}
