//
//  ModelManagerSheet.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2026-02-07.
//

import SwiftUI

struct ModelManagerSheet: View {
    @Binding var availableModels: [String]
    @Binding var selectedModel: String
    var refreshModels: (@escaping (Result<[String], Error>) -> Void) -> Void
    var addModel: (String, @escaping (Result<[String], Error>) -> Void) -> Void

    @State private var newModelName: String = ""
    @State private var statusMessage: String = "Tip: add a model name like qwen2.5:latest"
    @State private var isWorking: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var clearInputOnAlertDismiss: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ADD MODEL")) {
                    TextField("e.g. qwen2.5:latest", text: $newModelName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    Button {
                        pullModel()
                    } label: {
                        HStack {
                            if isWorking {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Text("Download and Add")
                        }
                    }
                    .disabled(isWorking || newModelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Current selection: \(selectedModel)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                Section(header: Text("AVAILABLE MODELS")) {
                    ForEach(availableModels, id: \.self) { model in
                        Button {
                            selectedModel = model
                        } label: {
                            HStack {
                                Text(model)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedModel == model {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }

                    Button("Refresh List (from Ollama)") {
                        reloadModels()
                    }
                    .disabled(isWorking)
                }
            }
            .navigationTitle("Manage Models")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Could Not Add Model", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {
                if clearInputOnAlertDismiss {
                    newModelName = ""
                    clearInputOnAlertDismiss = false
                }
            }
        } message: {
            Text(errorMessage)
        }
    }

    private func pullModel() {
        let requestedModel = newModelName.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedModel = normalizeModelName(requestedModel)
        isWorking = true
        statusMessage = requestedModel == resolvedModel
            ? "Downloading \(resolvedModel)..."
            : "No tag provided. Downloading \(resolvedModel)..."

        addModel(resolvedModel) { result in
            isWorking = false
            switch result {
            case .success(let models):
                availableModels = models
                if models.contains(resolvedModel) {
                    selectedModel = resolvedModel
                }
                statusMessage = "Model added successfully."
                newModelName = ""
            case .failure(let error):
                errorMessage = error.localizedDescription
                clearInputOnAlertDismiss = true
                showErrorAlert = true
                statusMessage = "Failed to add model. Check the alert message."
            }
        }
    }

    private func normalizeModelName(_ name: String) -> String {
        if name.contains(":") { return name }
        return "\(name):latest"
    }

    private func reloadModels() {
        isWorking = true
        statusMessage = "Refreshing model list..."

        refreshModels { result in
            isWorking = false
            switch result {
            case .success(let models):
                availableModels = models
                if !models.contains(selectedModel), let first = models.first {
                    selectedModel = first
                }
                statusMessage = "Model list updated."
            case .failure(let error):
                statusMessage = "Failed to refresh models: \(error.localizedDescription)"
            }
        }
    }
}
