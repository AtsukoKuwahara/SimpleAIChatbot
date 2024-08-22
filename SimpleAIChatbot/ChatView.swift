//
//  ChatView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-12.
//

import SwiftUI

struct ChatView: View {
    @Binding var userMessage: String
    @Binding var responseMessage: AttributedString
    @Binding var isLoading: Bool
    @Binding var selectedModel: String
    
    var fetchResponse: () -> Void
    
    @State private var showSettings: Bool = false
    @Binding var temperature: Double
    @Binding var seed: Int
    @Binding var top_k: Int
    
    let models = ["llama3.1", "llama3", "mistral"]

    var body: some View {
        NavigationView {
            ZStack {
                // Background Pattern
                Color.white
                    .opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Image("IMG_1576")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.15)
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                VStack(alignment: .leading) {
                    Text("OrangeBot")
                        .font(.custom("Courier-Bold", size: 38))
                        .foregroundColor(.orange)
                        .padding(.top, 20)
                    
                    // Text to guide model selection
                    Text("Select the Model")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                        .padding(.leading)
                    
                    Picker("Select Model", selection: $selectedModel) {
                        ForEach(models, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)
                    .shadow(radius: 2)
                    
                    TextField("Why is the sky blue?", text: $userMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                        .onSubmit {
                            fetchResponse()  // Send the message when "Enter" is pressed
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
                                    .stroke(Color.orange, lineWidth: 2) // Border to make the button pop
                            )
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    .onTapGesture {
                        // Press effect
                        withAnimation(.easeIn(duration: 0.2)) {
                            // Simulate press effect
                        }
                    }
                    
                    ScrollView {
                        if !isLoading {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(responseMessage)
                                    .font(.system(size: 18))
                                    .lineSpacing(4)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                        }
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    .opacity(isLoading ? 0 : 1) // Hide the ScrollView during loading
                    Spacer()
                }
                .padding()
                .navigationBarItems(trailing: Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gear")
                })
                .sheet(isPresented: $showSettings) {
                    SettingsView(temperature: $temperature, seed: $seed, top_k: $top_k)
                }
                if isLoading {
                    VStack {
                        Spacer()
                        VintageProgressBar()
                            .frame(width: 200, height: 20)
                        Spacer()
                    }
                }
            }
            
            
        }
    }
}

#Preview {
    ChatView(
        userMessage: .constant("Why is the sky blue?"),
        responseMessage: .constant(try! AttributedString(markdown: "The sky is blue because...")),
        isLoading: .constant(false),
        selectedModel: .constant("llama3.1"),
        fetchResponse: {}, // Empty closure for the preview
        temperature: .constant(0.8),
        seed: .constant(42),
        top_k: .constant(40)
    )
}
