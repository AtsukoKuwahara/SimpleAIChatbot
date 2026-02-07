//
//  SettingsView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var temperature: Double
    @Binding var seed: Int
    @Binding var top_k: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("TEMPERATURE")) {
                    settingDescription(
                        "Controls response style and creativity.",
                        hint: "Guide: 0.2 = factual, 0.8 = balanced, 1.0 = creative."
                    )

                    Slider(value: $temperature, in: 0...1, step: 0.1) {
                        Text("Temperature")
                    }
                    .tint(.orange)
                    Text("Current: \(temperature, specifier: "%.1f")")
                }

                Section(header: Text("SEED")) {
                    settingDescription(
                        "Sets the random seed used for generation.",
                        hint: "Same model + same prompt + same settings + same seed gives more reproducible outputs."
                    )

                    Stepper(value: $seed, in: 0...100) {
                        Text("Seed: \(seed)")
                    }
                }

                Section(header: Text("TOP K")) {
                    settingDescription(
                        "Controls how many candidate tokens are considered each step.",
                        hint: "Lower = stable and focused. Higher = broader and more diverse."
                    )

                    Stepper(value: $top_k, in: 10...100) {
                        Text("Top K: \(top_k)")
                    }
                }
            }
            .navigationTitle("Optional Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .accentColor(.orange)
        }
    }

    @ViewBuilder
    private func settingDescription(_ text: String, hint: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
            Text(hint)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 6)
    }
}

#Preview {
    SettingsView(temperature: .constant(0.7), seed: .constant(40), top_k: .constant(38))
}
