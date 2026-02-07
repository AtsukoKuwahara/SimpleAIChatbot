//
//  SimpleAIChatbotTests.swift
//  SimpleAIChatbotTests
//
//  Created by Atsuko Kuwahara on 2024-11-19.
//

import XCTest
@testable import SimpleAIChatbot

final class SimpleAIChatbotTests: XCTestCase {

    func testMakeRequestBuildsExpectedPayload() throws {
        let service = NetworkService(baseURL: URL(string: "http://localhost:11434")!)

        let request = try service.makeRequest(
            userMessage: "Why is the sky blue?",
            model: "llama3.1",
            temperature: 0.7,
            seed: 42,
            top_k: 40
        )

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "http://localhost:11434/api/chat")

        guard let body = request.httpBody else {
            XCTFail("Expected request body")
            return
        }

        let jsonObject = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        XCTAssertEqual(jsonObject?["model"] as? String, "llama3.1")
        XCTAssertEqual(jsonObject?["stream"] as? Bool, false)

        let messages = jsonObject?["messages"] as? [[String: String]]
        XCTAssertEqual(messages?.first?["role"], "user")
        XCTAssertEqual(messages?.first?["content"], "Why is the sky blue?")

        let options = jsonObject?["options"] as? [String: Any]
        XCTAssertEqual(options?["seed"] as? Int, 42)
        XCTAssertEqual(options?["top_k"] as? Int, 40)
        XCTAssertEqual(options?["temperature"] as? Double, 0.7)
    }

    func testDecodeChatEntryReturnsMessageContent() throws {
        let service = NetworkService(baseURL: URL(string: "http://localhost:11434")!)

        let responseData = """
        {
          "model": "llama3.1",
          "created_at": "2026-02-07T00:00:00Z",
          "message": {
            "role": "assistant",
            "content": "Rayleigh scattering causes the sky to appear blue."
          },
          "done": true
        }
        """.data(using: .utf8)!

        let entry = try service.decodeChatEntry(from: responseData, userMessage: "Why is the sky blue?", model: "llama3.1")

        XCTAssertEqual(entry.question, "Why is the sky blue?")
        XCTAssertEqual(entry.responseMarkdown, "Rayleigh scattering causes the sky to appear blue.")
        XCTAssertEqual(entry.modelName, "llama3.1")
    }

    func testDecodeChatEntryThrowsServerErrorForErrorPayload() {
        let service = NetworkService(baseURL: URL(string: "http://localhost:11434")!)

        let responseData = """
        {
          "error": "model 'llama3.1' not found"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(
            try service.decodeChatEntry(from: responseData, userMessage: "Hello", model: "llama3.1")
        ) { error in
            guard case NetworkError.serverError(let message) = error else {
                XCTFail("Expected NetworkError.serverError, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("not found"))
        }
    }
}
