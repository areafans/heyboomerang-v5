//
//  ContentView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = true // Set to true for prototype - normally would check user defaults
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingContainerView(showOnboarding: $showOnboarding)
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: showOnboarding)
    }
}

#Preview {
    ContentView()
}
