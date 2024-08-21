//
//  LoadingView.swift
//  SimpleAIChatbot
//
//  Created by Atsuko Kuwahara on 2024-08-08.
//

import SwiftUI

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

struct CustomLoadingView: View {
    @State private var isAnimating: Bool = false

    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(Color.orange, lineWidth: 8)
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear {
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
            }
    }
}

// Vintage Style Progress Bar
struct VintageProgressBar: View {
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geometry.size.width * progress, height: 20)
            }
            .onAppear {
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
