//
//  TimingSelectionView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 8/1/25.
//

import SwiftUI

struct TimingSelectionView: View {
    let task: ReviewTask
    @Binding var selectedTiming: TaskReviewFlow.TimingOption
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("When to send?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Choose the best time to send this message")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Timing Options
            VStack(spacing: 16) {
                ForEach(TaskReviewFlow.TimingOption.allCases, id: \.self) { option in
                    TimingOptionRow(
                        option: option,
                        isSelected: selectedTiming == option,
                        onTap: {
                            selectedTiming = option
                        }
                    )
                }
            }
            
            Spacer()
            
            // Message Preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Message preview:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(task.message)
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            Spacer()
            
            // Continue Button
            Button("Continue to Preview") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .navigationTitle("Timing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TimingOptionRow: View {
    let option: TaskReviewFlow.TimingOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.secondary, lineWidth: 2)
                        )
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Option info
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(timingDescription(for: option))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time indicator
                Text(timeDisplay(for: option))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timingDescription(for option: TaskReviewFlow.TimingOption) -> String {
        switch option {
        case .tomorrowAM:
            return "Send between 9:00 AM - 12:00 PM"
        case .tomorrowPM:
            return "Send between 1:00 PM - 5:00 PM"
        case .inTwoDays:
            return "Send in 2 days at 10:00 AM"
        }
    }
    
    private func timeDisplay(for option: TaskReviewFlow.TimingOption) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        switch option {
        case .tomorrowAM:
            return formatter.string(from: Date().addingTimeInterval(86400)) + " AM"
        case .tomorrowPM:
            return formatter.string(from: Date().addingTimeInterval(86400)) + " PM"
        case .inTwoDays:
            return formatter.string(from: Date().addingTimeInterval(172800))
        }
    }
}

#Preview {
    NavigationView {
        TimingSelectionView(
            task: ReviewTask(
                contactName: "Mary Johnson",
                message: "Thanks for letting us work on your kitchen demo today! The project is off to a great start."
            ),
            selectedTiming: .constant(.tomorrowAM),
            onContinue: {}
        )
    }
}