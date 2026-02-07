//
//  ChatView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//

import SwiftUI

/// Main view for interacting with the chatbot
struct ChatView: View {
    @Binding var userMessage: String
    @Binding var responseMessage: AttributedString
    @Binding var isLoading: Bool
    @Binding var selectedModel: String
    @Binding var availableModels: [String]
    
    var fetchResponse: () -> Void
    var refreshModels: (@escaping (Result<[String], Error>) -> Void) -> Void
    var addModel: (String, @escaping (Result<[String], Error>) -> Void) -> Void
    
    @State private var showSettings: Bool = false
    @State private var showModelGuide: Bool = false
    @State private var showModelManager: Bool = false
    @Binding var temperature: Double
    @Binding var seed: Int
    @Binding var top_k: Int
    
    private var modelGuides: [ModelGuide] {
        var guides: [ModelGuide] = []

        if let model = bestModelForFamily("llama3.1") {
            guides.append(
                .init(
                    title: "llama3.1",
                    modelValue: model,
                    speed: "Medium",
                    bestFor: "Balanced general chat",
                    note: "Good default for everyday questions."
                )
            )
        }

        if let model = bestModelForFamily("llama3.2") {
            guides.append(
                .init(
                    title: "llama3.2",
                    modelValue: model,
                    speed: "Medium",
                    bestFor: "Stronger reasoning",
                    note: "Useful for more detailed explanations."
                )
            )
        }

        if let model = bestModelForFamily("mistral") {
            guides.append(
                .init(
                    title: "mistral",
                    modelValue: model,
                    speed: "Fast",
                    bestFor: "Quick replies",
                    note: "Best when you want faster responses."
                )
            )
        }

        let selectedFamily = modelFamily(selectedModel)
        let knownFamilies = Set(guides.map(\.title))
        if !knownFamilies.contains(selectedFamily) {
            guides.append(
                .init(
                    title: selectedFamily,
                    modelValue: selectedModel,
                    speed: "Depends",
                    bestFor: "Custom local model",
                    note: "Selected model: \(selectedModel)"
                )
            )
        }
        return guides
    }

    private var recommendedModels: [String] {
        let preferredFamilies = ["llama3.1", "llama3.2", "mistral"]
        var result: [String] = []

        for family in preferredFamilies {
            if let match = bestModelForFamily(family) {
                result.append(match)
            }
        }

        if !result.contains(selectedModel) {
            result.append(selectedModel)
        }

        return result
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background with a subtle pattern
                Color.white
                    .opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Image("BackgroundPattern")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.15)
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                VStack(alignment: .leading) {
                    Text("OrangeBot")
                        .font(.custom("Courier-Bold", size: 48))
                        .foregroundColor(.orange)
                        .padding(.leading, 10)
                    
                    // Text to guide model selection
                    Text("Select the Model")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                        .padding(.leading)
                    
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(modelFamily(selectedModel))
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(selectedModel)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Menu {
                            Section("Recommended") {
                                ForEach(recommendedModels, id: \.self) { model in
                                    Button {
                                        selectedModel = model
                                    } label: {
                                        if selectedModel == model {
                                            Label(modelFamily(model), systemImage: "checkmark")
                                        } else {
                                            Text(modelFamily(model))
                                        }
                                    }
                                }
                            }
                            Divider()
                            Button("Manage Models...") {
                                showModelManager = true
                            }
                        } label: {
                            Label("Choose", systemImage: "chevron.down.circle")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.secondarySystemBackground).opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showModelGuide.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Model Guide")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: showModelGuide ? "chevron.up" : "chevron.down")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.secondarySystemBackground).opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)

                    if showModelGuide {
                        ModelGuideTable(
                            guides: modelGuides,
                            selectedModel: $selectedModel
                        )
                        .padding(.horizontal, 10)
                        .padding(.bottom, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    TextField("Why is the sky blue?", text: $userMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                        .onSubmit {
                            fetchResponse()  // Trigger response generation on Enter
                        }
                    
                    Button(action: {
                        fetchResponse()
                    }) {
                        Text("Send")
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    .disabled(userMessage.isEmpty)
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        if isLoading {
                            VStack(spacing: 10) {
                                VintageProgressBar()
                                    .frame(width: 200, height: 20)
                                Text("Generating response...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 14)
                            .padding(.bottom, 8)
                        } else if !responseMessage.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(responseMessage)
                                    .font(.system(size: 18))
                                    .lineSpacing(4)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Color.clear)
                }
                .padding()
                .navigationBarItems(trailing:
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 38, height: 38)
                            .background(Color(UIColor.systemBackground).opacity(0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    .buttonStyle(.plain)
                )
                .sheet(isPresented: $showModelManager) {
                    ModelManagerSheet(
                        availableModels: $availableModels,
                        selectedModel: $selectedModel,
                        refreshModels: refreshModels,
                        addModel: addModel
                    )
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(temperature: $temperature, seed: $seed, top_k: $top_k)
                }
            }
            
            
        }
    }
}

extension ChatView {
    private func modelFamily(_ modelName: String) -> String {
        let lower = modelName.lowercased()
        if lower.contains("llama3.2") { return "llama3.2" }
        if lower.contains("llama3.1") { return "llama3.1" }
        if lower.contains("mistral") { return "mistral" }
        if lower.contains("gemma3") { return "gemma3" }
        if lower.contains("codellama") { return "codellama" }
        return modelName.split(separator: ":").first.map(String.init) ?? modelName
    }

    private func bestModelForFamily(_ family: String) -> String? {
        let matches = availableModels.filter { modelFamily($0) == family }
        if matches.isEmpty { return nil }
        if let latest = matches.first(where: { $0.hasSuffix(":latest") }) {
            return latest
        }
        return matches.sorted(by: { $0.count < $1.count }).first
    }
}

private struct ModelGuide: Identifiable {
    let id = UUID()
    let title: String
    let modelValue: String
    let speed: String
    let bestFor: String
    let note: String
}

private struct ModelGuideTable: View {
    let guides: [ModelGuide]
    @Binding var selectedModel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Model Guide (tap to select)")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Text("Model")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Speed")
                        .frame(width: 58, alignment: .leading)
                    Text("Best For")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.caption2.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))

                ForEach(guides) { guide in
                    Button {
                        selectedModel = guide.modelValue
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                Text(guide.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.subheadline.weight(.semibold))
                                Text(guide.speed)
                                    .frame(width: 58, alignment: .leading)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(guide.bestFor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(guide.note)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            selectedModel == guide.modelValue
                            ? Color.orange.opacity(0.15)
                            : Color.clear
                        )
                    }
                    .buttonStyle(.plain)

                    if guide.id != guides.last?.id {
                        Divider()
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ChatView(
        userMessage: .constant("Why is the sky blue?"),
        responseMessage: .constant(try! AttributedString(markdown: "The sky is blue because...")),
        isLoading: .constant(true),
        selectedModel: .constant("llama3.1"),
        availableModels: .constant(["llama3.1", "llama3.2", "mistral"]),
        fetchResponse: {}, // Empty closure for the preview
        refreshModels: { completion in
            completion(.success(["llama3.1", "llama3.2", "mistral"]))
        },
        addModel: { _, completion in
            completion(.success(["llama3.1", "llama3.2", "mistral"]))
        },
        temperature: .constant(0.8),
        seed: .constant(42),
        top_k: .constant(40)
    )
}
