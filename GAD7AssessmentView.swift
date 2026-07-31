//
//  GAD7AssessmentView.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Generalized Anxiety Disorder (GAD-7) step-by-step diagnostic questionnaire.
//

import SwiftUI
import SwiftData

/// An interactive clinical diagnostic questionnaire that calculates anxiety levels.
public struct GAD7AssessmentView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - SwiftData Context
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - GAD-7 Survey Questions & Options
    
    private let questions = [
        "Feeling nervous, anxious, or on edge?",
        "Not being able to stop or control worrying?",
        "Worrying too much about different things?",
        "Trouble relaxing?",
        "Being so restless that it is hard to sit still?",
        "Becoming easily annoyed or irritable?",
        "Feeling afraid, as if something awful might happen?"
    ]
    
    private let options = [
        (text: "Not at all", score: 0),
        (text: "Several days", score: 1),
        (text: "More than half the days", score: 2),
        (text: "Nearly every day", score: 3)
    ]
    
    // MARK: - State Management
    
    @State private var currentQuestionIndex = 0
    @State private var answers: [Int] = Array(repeating: -1, count: 7)
    @State private var notes: String = ""
    @State private var isFinished = false
    @State private var showSaveSuccess = false
    @State private var showConsent = true
    @FocusState private var isNotesFocused: Bool
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Body View
    
    public var body: some View {
        ZStack {
            // Absolute dark slate foundation
            Color.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header Panel (Time Zones Redesigned style)
                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Anxiety Check-in")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: resetAssessment) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            withAnimation {
                                showConsent = true
                            }
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.top, 24)
                
                if showSaveSuccess {
                    successSplashView
                } else if showConsent {
                    consentDisclaimerView
                } else if isFinished {
                    summaryCheckInCard
                } else {
                    questionnaireCard
                }
                
                // Small permanent footnote disclaimer for App Store guidelines
                Text("This check-in is a screening tool. It does not provide medical diagnoses or replace professional consultation.")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 110) // Leave room for floating tab bar
        }
    }
    
    // MARK: - Subviews
    
    private var questionnaireCard: some View {
        VStack(spacing: 20) {
            // Question Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of 7")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                    Text("\(Int((Double(currentQuestionIndex + 1) / 7.0) * 100))%")
                        .font(.system(.footnote, design: .rounded).monospacedDigit())
                        .foregroundColor(.hapticGlow)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.hapticGlow)
                            .frame(width: geo.size.width * CGFloat(Double(currentQuestionIndex + 1) / 7.0))
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            // Question Content
            Text(questions[currentQuestionIndex])
                .font(.system(.title3, design: .default, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(height: 80)
            
            Spacer()
            
            // Multiple Choice Options (Redesigned as stacked colored rows)
            VStack(spacing: 0) {
                let colors: [Color] = [.rowGray, .rowBlue, .rowMagenta, .rowPurple]
                
                ForEach(Array(options.enumerated()), id: \.element.score) { index, option in
                    let isSelected = answers[currentQuestionIndex] == option.score
                    let backgroundColor = colors[option.score % colors.count]
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            answers[currentQuestionIndex] = option.score
                        }
                    }) {
                        HStack {
                            Circle()
                                .fill(isSelected ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .padding(.trailing, 4)
                            
                            Text(option.text)
                                .font(.system(.body, design: .rounded, weight: .bold))
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                            } else {
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(backgroundColor.opacity(isSelected ? 1.0 : 0.35))
                        .cornerRadius(index == 0 ? 16 : 0, corners: [.topLeft, .topRight])
                        .cornerRadius(index == options.count - 1 ? 16 : 0, corners: [.bottomLeft, .bottomRight])
                    }
                }
            }
            .cornerRadius(16)
            
            Spacer()
            
            // Flow Buttons
            HStack(spacing: 16) {
                if currentQuestionIndex > 0 {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            currentQuestionIndex -= 1
                        }
                    }) {
                        Text("Back")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                    }
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        if currentQuestionIndex < 6 {
                            currentQuestionIndex += 1
                        } else {
                            isFinished = true
                        }
                    }
                }) {
                    Text(currentQuestionIndex == 6 ? "Finish" : "Next")
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(answers[currentQuestionIndex] != -1 ? Color.hapticGlow : Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                .disabled(answers[currentQuestionIndex] == -1)
            }
        }
        .padding(24)
        .background(Color.rowGray)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var summaryCheckInCard: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Assessment Summary")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.hapticGlow)
                
                // Diagnostic Score Panel
                VStack(spacing: 8) {
                    Text("\(totalScore)")
                        .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundColor(severityColor)
                    
                    Text("Total GAD-7 Score")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(severityLevel.uppercased())
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundColor(severityColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(severityColor.opacity(0.12))
                        .cornerRadius(12)
                        .padding(.top, 4)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.04))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                
                // App Store/Clinical safety: Crisis Support if anxiety severity is Moderate/Severe (Score >= 10)
                if totalScore >= 10 {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.accentRelease)
                            Text("Support & Crisis Resources")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Your score indicates moderate-to-severe anxiety levels. If you are feeling overwhelmed, distressed, or need help, please connect with these free, confidential clinical networks:")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(2)
                        
                        Divider().background(Color.white.opacity(0.12))
                        
                        VStack(spacing: 10) {
                            Link(destination: URL(string: "tel:988")!) {
                                HStack {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.system(size: 18))
                                    Text("988 Suicide & Crisis Lifeline")
                                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                                    Spacer()
                                    Text("Call/Text 988")
                                        .font(.system(.caption2, design: .rounded).bold())
                                        .foregroundColor(.white.opacity(0.5))
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.hapticGlow)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(8)
                            }
                            
                            Link(destination: URL(string: "sms:741741&body=HOME")!) {
                                HStack {
                                    Image(systemName: "message.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Crisis Text Line")
                                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                                    Spacer()
                                    Text("Text HOME to 741741")
                                        .font(.system(.caption2, design: .rounded).bold())
                                        .foregroundColor(.white.opacity(0.5))
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.hapticGlow)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(8)
                            }
                            
                            Link(destination: URL(string: "https://findahelpline.com")!) {
                                HStack {
                                    Image(systemName: "globe")
                                        .font(.system(size: 16))
                                    Text("International Support Directories")
                                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.hapticGlow)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.accentRelease.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentRelease.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Counselor Reflection Notes
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Reflection Notes")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(notes.count)/500")
                            .font(.system(.caption2, design: .rounded).monospacedDigit())
                            .foregroundColor(notes.count > 500 ? .accentRelease : .white.opacity(0.4))
                    }
                    
                    TextField("Add notes for your practitioner...", text: $notes, axis: .vertical)
                        .focused($isNotesFocused)
                        .onChange(of: notes) { _, newValue in
                            if newValue.count > 500 {
                                notes = String(newValue.prefix(500))
                            }
                        }
                        .lineLimit(4...6)
                        .font(.system(.body, design: .default))
                        .padding(14)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isNotesFocused = false
                                }
                                .bold()
                                .foregroundColor(.hapticGlow)
                            }
                        }
                }
                
                // Save and Cancel Actions
                VStack(spacing: 12) {
                    Button(action: saveAssessment) {
                        Text("Save Assessment")
                            .font(.system(.body, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color.hapticGlow)
                            .cornerRadius(14)
                    }
                    
                    Button(action: resetAssessment) {
                        Text("Retake Test")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.clear)
                    }
                }
            }
            .padding(24)
            .background(Color.rowGray)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    private var successSplashView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.accentHold)
                .shadow(color: .accentHold.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("Assessment Saved")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            
            Text("Your GAD-7 record has been added to your local database. You can export this to your therapist anytime.")
                .font(.system(.body, design: .default))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: resetAssessment) {
                Text("Start New Check-in")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(Color.hapticGlow)
                    .cornerRadius(24)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var consentDisclaimerView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.below.ecg.fill")
                .font(.system(size: 48))
                .foregroundColor(.hapticGlow)
                .shadow(color: .hapticGlow.opacity(0.2), radius: 8)
                .padding(.top, 12)
            
            Text("Clinical Screening Disclaimer")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("This screening is based on the Generalized Anxiety Disorder 7-item (GAD-7) scale, a clinically validated questionnaire for assessing anxiety symptoms over the last 2 weeks.")
                    .font(.system(.footnote, design: .default))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(3)
                
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.accentHold)
                        .font(.system(size: 14))
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Not a Medical Diagnosis")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                        Text("A high score is a general indicator and does NOT confirm a diagnosis. Diagnostic evaluations must only be performed by a qualified doctor or mental health professional.")
                            .font(.system(.caption2, design: .default))
                            .foregroundColor(.white.opacity(0.65))
                            .lineSpacing(2)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(10)
                
                Text("IMPORTANT: If you are experiencing high levels of distress or having thoughts of self-harm, please seek immediate help from crisis lifelines or contact a practitioner.")
                    .font(.system(.footnote, design: .default, weight: .medium))
                    .foregroundColor(.accentRelease)
                    .lineSpacing(3)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showConsent = false
                }
            }) {
                Text("I Understand & Consent")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.hapticGlow)
                    .cornerRadius(14)
                    .shadow(color: Color.hapticGlow.opacity(0.25), radius: 8, x: 0, y: 4)
            }
        }
        .padding(24)
        .background(Color.rowGray)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - Logic Calculations
    
    private var totalScore: Int {
        answers.filter { $0 != -1 }.reduce(0, +)
    }
    
    private var severityLevel: String {
        switch totalScore {
        case 0...4: return "Minimal Anxiety"
        case 5...9: return "Mild Anxiety"
        case 10...14: return "Moderate Anxiety"
        default: return "Severe Anxiety"
        }
    }
    
    private var severityColor: Color {
        switch totalScore {
        case 0...4: return .white.opacity(0.6)
        case 5...9: return .accentHold
        case 10...14: return .hapticGlow
        default: return .accentRelease
        }
    }
    
    private func saveAssessment() {
        // Sanitize control characters to prevent SQLite/SwiftData corruption
        let sanitizedNotes = notes.filteringControlCharacters()
        let newRecord = GAD7Assessment(score: totalScore, notes: sanitizedNotes)
        modelContext.insert(newRecord)
        
        do {
            try modelContext.save()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                showSaveSuccess = true
            }
        } catch {
            print("[GAD7AssessmentView] Error saving check-in: \(error.localizedDescription)")
        }
    }
    
    private func resetAssessment() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            currentQuestionIndex = 0
            answers = Array(repeating: -1, count: 7)
            notes = ""
            isFinished = false
            showSaveSuccess = false
            showConsent = true
        }
    }
}



#Preview {
    GAD7AssessmentView()
        .modelContainer(for: [GroundingSession.self, GAD7Assessment.self], inMemory: true)
}
