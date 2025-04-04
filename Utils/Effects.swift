//
//  FireworkView.swift
//  weisswein
//
//  Created by Phuc on 3/4/25.
//
import SwiftUI

struct FireworkView: View {
    @State private var animate = false
    let colors: [Color] = [.red, .blue, .yellow, .green, .purple, .white, .pink] // Firework colors

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { _ in // Create multiple fireworks
                FireworkParticlesView(animate: $animate, color: colors.randomElement() ?? .yellow)
            }
        }
        .onAppear {
            animate.toggle()
        }
    }
}

struct FireworkParticlesView: View {
    @Binding var animate: Bool
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(color.opacity(0.8))
                    .frame(width: 10, height: 5)
                    .offset(x: animate ? CGFloat.random(in: -50...50) : 0,
                            y: animate ? CGFloat.random(in: -50...50) : 0)
                    .opacity(animate ? 0 : 1)
                    .animation(Animation.easeOut(duration: 0.6).delay(Double(i) * 0.02), value: animate)
            }
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}


struct FullScreenBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            // Use the new recommended approach for iOS 15+
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                view.frame = window.bounds
                window.insertSubview(view, at: 0)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Nothing to update
    }
}
