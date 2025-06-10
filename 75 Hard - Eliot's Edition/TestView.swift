//
//  TestView.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🔥 LOCK IN APP 🔥")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Day 1 of 75")
                .font(.title)
            
            Text("If you see this, the new app is working!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Test Button") {
                print("✅ Test button tapped")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            print("✅ TestView appeared successfully")
        }
    }
}

#Preview {
    TestView()
}