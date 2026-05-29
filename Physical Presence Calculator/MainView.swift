//
//  MainView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

enum TrackingGoal: String, CaseIterable, Identifiable {
    case pr = "PR Status"
    case citizenship = "Citizenship"
    var id: String { self.rawValue }
    
    var targetDays: Int {
        self == .pr ? 730 : 1095
    }
}

struct MainView: View {
    @ObservedObject var travelData: TravelData
    
    // State to track which goal the user has selected
    @State private var selectedGoal: TrackingGoal = .citizenship

    // Compute presence days using the current instance's travelData when needed
    var totalPresenceDays: Int {
        daysInCanada(travelData: travelData, referenceDate: Date.now)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Premium background styling
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Ambient glows matching OnboardingView
                VStack {
                    HStack {
                        Circle()
                            .fill(selectedGoal == .pr ? Color.green.opacity(0.06) : Color.blue.opacity(0.06))
                            .frame(width: 250, height: 250)
                            .blur(radius: 50)
                            .offset(x: -80, y: -50)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(selectedGoal == .pr ? Color.teal.opacity(0.06) : Color.purple.opacity(0.06))
                            .frame(width: 250, height: 250)
                            .blur(radius: 50)
                            .offset(x: 80, y: 50)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Goal Switcher Card
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "target")
                                    .font(.headline)
                                    .foregroundStyle(selectedGoal == .pr ? .green : .blue)
                                Text("Tracking Goal")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            
                            Picker("Goal", selection: $selectedGoal) {
                                ForEach(TrackingGoal.allCases) { goal in
                                    Text(goal.rawValue).tag(goal)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                        .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                        
                        // Circular Progress Card
                        VStack(spacing: 24) {
                            HStack {
                                Text("Physical Presence Progress")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(Double(totalPresenceDays) / Double(selectedGoal.targetDays) * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(selectedGoal == .pr ? .green : .blue)
                            }
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 22)
                                
                                Circle()
                                    .trim(from: 0, to: min(1, max(0, CGFloat(totalPresenceDays) / CGFloat(selectedGoal.targetDays))))
                                    .stroke(
                                        selectedGoal == .pr 
                                            ? LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                                            : LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
                                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: (selectedGoal == .pr ? Color.green : Color.blue).opacity(0.2), radius: 6, x: 0, y: 3)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedGoal)
                                
                                VStack(spacing: 4) {
                                    Text("\(Int(totalPresenceDays))")
                                        .font(.system(size: 50, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                    
                                    Text("of \(Int(selectedGoal.targetDays)) days")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(width: 210, height: 210)
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            // Visual horizontal stats
                            HStack {
                                Spacer()
                                statItem(
                                    value: "\(totalPresenceDays)",
                                    label: "Completed",
                                    icon: "checkmark.circle.fill",
                                    color: selectedGoal == .pr ? .green : .blue
                                )
                                Spacer()
                                Divider().frame(height: 35)
                                Spacer()
                                statItem(
                                    value: "\(max(0, selectedGoal.targetDays - totalPresenceDays))",
                                    label: "Remaining",
                                    icon: "hourglass",
                                    color: .orange
                                )
                                Spacer()
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 24).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                        .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                        
                        // Status Alert Card
                        let isMet = (selectedGoal.targetDays - totalPresenceDays) <= 0
                        let statusIcon = isMet ? "checkmark.seal.fill" : "info.circle.fill"
                        let statusColor: Color = isMet ? .green : (selectedGoal == .pr ? .green : .blue)
                        let statusCardBg: Color = isMet ? Color.green.opacity(0.06) : (selectedGoal == .pr ? Color.green.opacity(0.04) : Color.blue.opacity(0.04))
                        let statusCardStroke: Color = isMet ? Color.green.opacity(0.2) : (selectedGoal == .pr ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                        
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: statusIcon)
                                .font(.title)
                                .foregroundStyle(statusColor)
                                .padding(.top, 2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isMet ? "Requirement Met" : "Status Tracker")
                                    .font(.headline)
                                    .foregroundStyle(isMet ? .green : .primary)
                                
                                Text(statusMessage)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(statusCardBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(statusCardStroke, lineWidth: 1)
                                )
                        )
                        
                        // New Personal Summary Card
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.text.rectangle")
                                    .font(.title3)
                                    .foregroundStyle(.purple)
                                
                                Text("Residency Standing")
                                    .font(.headline)
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PR Obtained")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(travelData.initDate.toString(style: .long))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Time as PR")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(travelData.daysSincePR() ?? 0) Days")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            if !travelData.exemptions.isEmpty {
                                Divider()
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Exemption Days")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("\(travelData.exemptions.reduce(0) { $0 + $1.durationInDays }) Days")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.green)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                        .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
        }
    }
    
    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundStyle(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var statusMessage: String {
        let remaining = Int(selectedGoal.targetDays - totalPresenceDays)
        if remaining <= 0 {
            return "🎉 You have met the physical presence requirement for \(selectedGoal.rawValue)!"
        } else {
            return "You need \(remaining) more days in Canada to qualify for \(selectedGoal.rawValue)."
        }
    }
}

#Preview {
    MainView(travelData: TravelData())
}
