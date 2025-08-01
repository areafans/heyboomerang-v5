//
//  TasksView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct TasksView: View {
    @State private var hasTasks = true // Toggle for empty state testing
    
    var body: some View {
        if hasTasks {
            TaskReviewFlow()
        } else {
            // Empty state when no tasks
            NavigationView {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("All caught up!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("New tasks from your voice captures will appear here for review")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxHeight: .infinity)
                .navigationTitle("Tasks")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}


#Preview {
    TasksView()
}