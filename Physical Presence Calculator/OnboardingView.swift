//
//  OnboardingView.swift
//  Physical Presence Calculator
//
//  Created by Antigravity on 2026-05-28.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var travelData: TravelData
    @Binding var hasCompletedOnboarding: Bool
    
    @State private var currentStep = 1
    @State private var acknowledgedDisclaimer = false
    @State private var animateIcon = false
    
    var body: some View {
        ZStack {
            // Premium background styling
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            // Subtle ambient glows
            VStack {
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.08))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: -80, y: -80)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.purple.opacity(0.08))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: 80, y: 80)
                }
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if currentStep == 1 {
                        stepOneWelcome
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        stepTwoPRDate
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animateIcon = true
            }
        }
    }
    
    // MARK: - Step 1: Welcome & Official Warning
    private var stepOneWelcome: some View {
        VStack(spacing: 28) {
            // Animated Header Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 96, height: 96)
                    .scaleEffect(animateIcon ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateIcon)
                
                Image(systemName: "hand.raised.shield.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .padding(.top, 20)
            
            // Sleek welcome titles
            VStack(spacing: 6) {
                Text("Physical Presence")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Calculator")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                
                Text("Your unofficial guide to Canadian residency tracking")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            
            // Features card
            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "calendar.badge.clock",
                    color: .blue,
                    title: "Log Travel Records",
                    subtitle: "Record departure and entry dates with ports of entry."
                )
                
                featureRow(
                    icon: "chart.bar.fill",
                    color: .purple,
                    title: "Monitor Requirements",
                    subtitle: "Calculate active physical presence days inside a rolling window."
                )
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
            .shadow(color: .black.opacity(0.03), radius: 10, y: 4)
            
            // Official Warning Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.title3)
                    
                    Text("Official Rules Warning")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                Text("This application is an **unofficial** tool designed strictly to assist in travel tracking. It is **not** associated with or endorsed by the Government of Canada.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Text("You must **always** refer to the official resources and guidelines of the **Government of Canada** for official regulations, residency rules, and final calculations.")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.orange.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                    )
            )
            
            Spacer(minLength: 10)
            
            // Required Checkbox Acknowledgment
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    acknowledgedDisclaimer.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: acknowledgedDisclaimer ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(acknowledgedDisclaimer ? Color.blue : Color.secondary)
                        .contentShape(Rectangle())
                    
                    Text("I understand that this is an unofficial calculator and agree to always refer to the Government of Canada for official rules.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .buttonStyle(.plain)
            
            // Continue Button
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    currentStep = 2
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(
                    acknowledgedDisclaimer
                    ? LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color(uiColor: .systemGray4)], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: acknowledgedDisclaimer ? .blue.opacity(0.3) : .clear, radius: 8, y: 4)
            }
            .disabled(!acknowledgedDisclaimer)
        }
    }
    
    // MARK: - Step 2: PR Date Setup
    private var stepTwoPRDate: some View {
        VStack(spacing: 28) {
            // Header
            VStack(spacing: 8) {
                Text("Permanent Residency")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Set Your PR Date")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing)
                    )
                
                Text("We use this date to correctly bound your rolling 5-year calculations under Canadian residency rules.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.top, 10)
            
            // Calendar picker card
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    Text("Date PR Obtained")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                
                DatePicker(
                    "PR Date",
                    selection: $travelData.initDate,
                    in: ...Date.now,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .environment(\.timeZone, TimeZone(identifier: "Canada/Central") ?? TimeZone.current)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(uiColor: .systemGroupedBackground)))
                
                HStack {
                    Text("Selected Date:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(travelData.initDate.toString(style: .long))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(uiColor: .secondarySystemGroupedBackground)))
            .shadow(color: .black.opacity(0.03), radius: 10, y: 4)
            
            Spacer(minLength: 20)
            
            // Complete Button
            Button {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                    hasCompletedOnboarding = true
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Start Tracking")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            }
        }
    }
    
    // MARK: - Helper Views
    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingView(travelData: TravelData(), hasCompletedOnboarding: .constant(false))
}
