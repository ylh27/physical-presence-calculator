//
//  MainView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI
import SwiftData

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
    
    @Environment(\.modelContext) private var modelContext
    //@Query private var trips: [Trip]
    
    // State to track which goal the user has selected
    @State private var selectedGoal: TrackingGoal = .citizenship
    
    // User data (Mocked)
    let landingDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1))!
    let arrivalInCanada = Calendar.current.date(from: DateComponents(year: 2022, month: 6, day: 1))!

    // Compute presence days using the current instance's travelData when needed
    var totalPresenceDays: Int {
        daysInCanada(travelData: travelData, referenceDate: Date.now)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Goal Switcher
                Picker("Goal", selection: $selectedGoal) {
                    ForEach(TrackingGoal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // The Circular Dashboard
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 22)
                    
                    Circle()
                        .trim(from: 0, to: min(1, max(0, CGFloat(totalPresenceDays) / CGFloat(selectedGoal.targetDays))))
                        .stroke(
                            selectedGoal == .pr ? Color.green.gradient : Color.blue.gradient,
                            style: StrokeStyle(lineWidth: 22, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedGoal)
                    
                    VStack {
                        Text("\(Int(totalPresenceDays))")
                            .font(.system(size: 55, weight: .bold, design: .rounded))
                        Text("of \(Int(selectedGoal.targetDays)) days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 250, height: 250)
                .padding()

                // Forecast Text
                Text(statusMessage)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.secondary.opacity(0.1)))

                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
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

//#Preview {
//    MainView(travelData: TravelData())
//}
