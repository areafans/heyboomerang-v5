//
//  SimpleTestView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct SimpleTestView: View {
    var body: some View {
        VStack {
            Text("Hello Boomerang!")
                .font(.title)
                .padding()
            
            Button("Test Button") {
                print("Button tapped")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    SimpleTestView()
}