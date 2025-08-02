//
//  DashboardView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct DashboardView: View {
    // Mock AI performance data
    @State private var monthlyRevenue = 18750
    @State private var weeklyMessages = 23
    @State private var aiSuccessRate = 0.89
    @State private var responseRate = 0.34
    @State private var aiLearningScore = 0.92
    @State private var automationSavings = 12.5 // hours per week
    
    private var userName = "Mike" // In real app, would come from user data
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    // Page Header (like Capture page)
                    VStack(spacing: 8) {
                        Text("Your AI Assistant")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("While you focus on your business, your AI has been working...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    // At a Glance Section
                    atAGlanceSection
                    
                    // Business Impact Cards
                    businessImpactSection
                    
                    // AI Performance Section
                    aiPerformanceSection
                    
                    // Smart Insights Section
                    smartInsightsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Boomerang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // MARK: - At a Glance Section
    private var atAGlanceSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("At a Glance")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text("\(weeklyMessages) messages crafted with your unique voice")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("\(Int(responseRate * 100))% of clients responded positively")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Business Impact Section  
    private var businessImpactSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Business Impact")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Revenue Impact Card
                BusinessImpactCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: .green,
                    title: "Revenue Pipeline",
                    value: "$\(monthlyRevenue)",
                    subtitle: "Potential bookings this month",
                    backgroundColor: Color.green.opacity(0.1)
                )
                
                HStack(spacing: 12) {
                    // Time Savings Card
                    BusinessImpactCard(
                        icon: "clock.fill",
                        iconColor: .blue,
                        title: "Time Saved",
                        value: "\(String(format: "%.1f", automationSavings))h",
                        subtitle: "Per week",
                        backgroundColor: Color.blue.opacity(0.1),
                        isCompact: true
                    )
                    
                    // Response Rate Card
                    BusinessImpactCard(
                        icon: "bubble.right.fill",
                        iconColor: .orange,
                        title: "Response Rate",
                        value: "\(Int(responseRate * 100))%",
                        subtitle: "Client engagement",
                        backgroundColor: Color.orange.opacity(0.1),
                        isCompact: true
                    )
                }
            }
        }
    }
    
    // MARK: - AI Performance Section
    private var aiPerformanceSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(.purple)
                Text("AI Performance")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // AI Success Rate
                AIPerformanceRow(
                    icon: "checkmark.seal.fill",
                    iconColor: .green,
                    title: "Task Generation Accuracy",
                    percentage: aiSuccessRate,
                    subtitle: "Messages approved without edits"
                )
                
                // Learning Progress
                AIPerformanceRow(
                    icon: "graduationcap.fill",
                    iconColor: .blue,
                    title: "Learning Progress",
                    percentage: aiLearningScore,
                    subtitle: "Understanding your business style"
                )
                
                // Automation Efficiency
                AIPerformanceRow(
                    icon: "gearshape.2.fill",
                    iconColor: .orange,
                    title: "Automation Efficiency",
                    percentage: 0.95,
                    subtitle: "Zero manual follow-ups needed"
                )
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Smart Insights Section
    private var smartInsightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("AI Insights")
                    .font(.headline)  
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                SmartInsightCard(
                    insight: "Your Tuesday morning messages get 47% more responses",
                    actionable: true
                )
                
                SmartInsightCard(
                    insight: "Follow-ups mentioning 'timeline' convert 3x better",
                    actionable: false
                )
                
                SmartInsightCard(
                    insight: "Johnson Family responds fastest to casual tone messages",
                    actionable: false
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct BusinessImpactCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    let backgroundColor: Color
    var isCompact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: isCompact ? 16 : 18))
                Spacer()
            }
            
            Text(value)
                .font(isCompact ? .title2 : .largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(isCompact ? 12 : 16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct AIPerformanceRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let percentage: Double
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(percentage * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(iconColor)
                
                // Progress bar
                ProgressView(value: percentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: iconColor))
                    .frame(width: 60)
            }
        }
    }
}

struct SmartInsightCard: View {
    let insight: String
    let actionable: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: actionable ? "star.fill" : "info.circle.fill")
                .foregroundColor(actionable ? .yellow : .blue)
                .font(.system(size: 14))
            
            Text(insight)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            if actionable {
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    DashboardView()
}