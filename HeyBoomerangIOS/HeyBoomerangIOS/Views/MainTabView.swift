//
//  MainTabView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 2 // Start with Capture tab selected
    @State private var pendingTasksCount = 5 // Mock data - would come from API
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Summary (Morning results from previous day)
            SummaryView()
                .tabItem {
                    Image(systemName: "sun.max.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Summary")
                }
                .tag(0)
            
            // Tasks (Evening review and approval)
            TasksView(pendingTasksCount: $pendingTasksCount)
                .tabItem {
                    Image(systemName: "moon.stars.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Tasks")
                }
                .badge(pendingTasksCount > 0 ? "\(pendingTasksCount)" : nil)
                .tag(1)
            
            // Voice Capture (Center tab)
            VoiceCaptureView()
                .tabItem {
                    Image(systemName: "mic.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Capture")
                }
                .tag(2)
            
            // Dashboard (Metrics)
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Dashboard")
                }
                .tag(3)
            
            // Profile (Settings)
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}