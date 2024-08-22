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
                    Text("Controls the creativity of the model. Higher values lead to more creative responses.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)

                    Slider(value: $temperature, in: 0...1, step: 0.1) {
                        Text("Temperature")
                    }
                    .tint(.orange)
                    Text("Current: \(temperature, specifier: "%.1f")")
                }

                Section(header: Text("SEED")) {
                    Text("Sets the random number seed. The same seed will generate the same response.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)

                    Stepper(value: $seed, in: 0...100) {
                        Text("Seed: \(seed)")
                    }
                }

                Section(header: Text("TOP K")) {
                    Text("Reduces the probability of generating nonsense. Higher values allow more diverse answers.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)

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
}

#Preview {
    SettingsView(temperature: .constant(0.7), seed: .constant(40), top_k: .constant(38))
}
