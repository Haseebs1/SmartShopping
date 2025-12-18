//
//  SplashScreenLoading.swift
//  SmartShopping
//
//  Created by user279038 on 12/2/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App icon/logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1 : 0.8)
                        .opacity(isAnimating ? 1 : 0)
                    
                    Image(systemName: "cart.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .opacity(isAnimating ? 1 : 0)
                }
                
                // App name with animation
                VStack(spacing: 8) {
                    Text("Smart")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    Text("Shopping")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                
                // Tagline
                Text("Shop Smarter, Live Better")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 10)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.2)
                    .padding(.top, 30)
                    .opacity(isAnimating ? 1 : 0)
            }
            .padding()
        }
        .onAppear {
            // Start animations with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    isAnimating = true
                }
            }
        }
    }
}
