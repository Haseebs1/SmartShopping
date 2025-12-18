//
//  LoadingView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 15) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Retry", action: onRetry)
                    .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .ignoresSafeArea()
    }
}
