//
//  LoadingView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-08.
//

import SwiftUI

/// A simple loading view with a circular progress indicator and background styling.
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .foregroundColor(.white)
        }
        .background(Color.orange.opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

/// A custom loading animation with a rotating circle.
struct CustomLoadingView: View {
    @State private var isAnimating: Bool = false

    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7) // Shows a partial arc of the circle
            .stroke(Color.orange, lineWidth: 8) // Styled as an orange stroke
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0)) // Rotates continuously
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
            .onDisappear { isAnimating = false }
    }
}

/// A vintage-style progress bar with animated gradient fill.
struct VintageProgressBar: View {
    @State private var progress: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                
                // Animated gradient progress
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .yellow]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 20)
            }
            .onAppear {
                // Animates the progress bar indefinitely
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                    progress = 1.0
                }
            }
        }
    }
}

#Preview {
    VintageProgressBar()
}
