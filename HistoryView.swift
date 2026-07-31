//
//  HistoryView.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Historical logs dashboard utilizing Swift Charts and ShareLink reports.
//

import SwiftUI
import SwiftData
import Charts

/// A dashboard view illustrating grounding trends, anxiety logs, and clinician PDF exports.
public struct HistoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - SwiftData Queries
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \GroundingSession.date, order: .reverse)
    private var sessions: [GroundingSession]
    
    @Query(sort: \GAD7Assessment.date, order: .reverse)
    private var assessments: [GAD7Assessment]
    
    // MARK: - State Management
    
    @State private var reportURL: URL?
    @State private var showDeleteConfirmation = false
    @State private var showAssessmentSheet = false
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Body View
    
    public var body: some View {
        ZStack {
            // Absolute dark slate foundation
            Color.backgroundDark
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title Header (Time Zones Redesigned style)
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
                        
                        Text("History & Analytics")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Circle())
                            }
                            
                            Group {
                                if let reportURL = reportURL {
                                    ShareLink(item: reportURL) {
                                        Image(systemName: "doc.richtext.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 44, height: 44)
                                            .background(Color.white.opacity(0.08))
                                            .clipShape(Circle())
                                    }
                                } else {
                                    Image(systemName: "doc.richtext")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white.opacity(0.3))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.04))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding(.top, 24)
                    
                    // PDF Exporter Share Link Panel
                    exportPanelSection
                    
                    // HIPAA Privacy Banner Card
                    privacyDisclosureCard
                    
                    // GAD-7 Charts Section
                    gad7ChartSection
                    
                    // Session Log History List Section
                    sessionLogsListSection
                    
                    Spacer()
                        .frame(height: 120) // Ensure spacing for the floating tab bar
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            updateReportURL()
        }
        .onDisappear {
            // Clean up temporary PDF file on exit to prevent storage bloating
            if let url = reportURL {
                try? FileManager.default.removeItem(at: url)
            }
        }
        .onChange(of: sessions.count) { _, _ in
            updateReportURL()
        }
        .onChange(of: assessments.count) { _, _ in
            updateReportURL()
        }
        .sheet(isPresented: $showAssessmentSheet) {
            GAD7AssessmentView()
        }
    }
    
    // MARK: - Subviews
    
    private var exportPanelSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Practitioner Report")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    Text("Export the last 30 days of wellness logs.")
                        .font(.system(.caption, design: .default))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                
                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.hapticGlow)
            }
            
            if sessions.isEmpty && assessments.isEmpty {
                Text("No data available to export yet.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else if let reportURL = reportURL {
                ShareLink(item: reportURL) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text("Share HIPAA-Compliant PDF")
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.hapticGlow)
                    .cornerRadius(12)
                    .shadow(color: Color.hapticGlow.opacity(0.2), radius: 8, x: 0, y: 4)
                }
            } else {
                Button(action: {}) {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Preparing Practitioner Report...")
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.hapticGlow.opacity(0.5))
                    .cornerRadius(12)
                }
                .disabled(true)
            }
        }
        .padding(20)
        .background(Color.rowGray)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var gad7ChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ANXIETY SEVERITY TREND (GAD-7)")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1.0)
                Spacer()
                Button(action: {
                    showAssessmentSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("Check-in")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
            }
            
            if assessments.isEmpty {
                PremiumEmptyState(
                    iconName: "chart.xyaxis.line",
                    title: "No Trends Recorded Yet",
                    subtitle: "Complete a weekly GAD-7 assessment to visualize your progress over time.",
                    height: 180
                )
            } else {
                Chart {
                    ForEach(assessments) { assessment in
                        // Visual progression line
                        LineMark(
                            x: .value("Date", assessment.date),
                            y: .value("Score", assessment.score)
                        )
                        .foregroundStyle(Color.hapticGlow)
                        .interpolationMethod(.monotone)
                        
                        // Precise dot markers
                        PointMark(
                            x: .value("Date", assessment.date),
                            y: .value("Score", assessment.score)
                        )
                        .foregroundStyle(Color.hapticGlow)
                        
                        // Faint gradient fill beneath the curve
                        AreaMark(
                            x: .value("Date", assessment.date),
                            y: .value("Score", assessment.score)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.hapticGlow.opacity(0.15), Color.hapticGlow.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYScale(domain: 0...21)
                .chartYAxis {
                    AxisMarks(values: [0, 5, 10, 15, 21]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel().foregroundStyle(Color.white.opacity(0.5))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel().foregroundStyle(Color.white.opacity(0.5))
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(20)
        .background(Color.rowGray)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var sessionLogsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT GROUNDING LOGS")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1.0)
            
            if sessions.isEmpty {
                PremiumEmptyState(
                    iconName: "hand.tap",
                    title: "No Grounding Logs",
                    subtitle: "Complete a Free Touch or Breathwork session to start tracking your sensory regulation.",
                    height: 120
                )
            } else {
                VStack(spacing: 0) { // Stacked rows with zero spacing matching screenshot
                    let colors: [Color] = [.rowGray, .rowBlue, .rowMagenta, .rowPurple, .rowDeepPurple]
                    
                    ForEach(Array(sessions.prefix(10).enumerated()), id: \.element.id) { index, session in
                        let backgroundColor = colors[index % colors.count]
                        
                        HStack(spacing: 16) {
                            // Status Dot
                            Circle()
                                .fill(session.protocolType.contains("Breath") ? Color.accentHold : Color.hapticGlow)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.protocolType)
                                    .font(.system(.body, design: .default, weight: .bold))
                                    .foregroundColor(.white)
                                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(.white.opacity(0.65))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "%d:%02ds", Int(session.duration) / 60, Int(session.duration) % 60))
                                    .font(.system(.title3, design: .rounded).bold().monospacedDigit())
                                    .foregroundColor(.white)
                                
                                Text(String(format: "Avg Force: %.0f%%", session.averagePressure * 100))
                                    .font(.system(.caption2, design: .rounded).bold())
                                    .foregroundColor(.white.opacity(0.65))
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(backgroundColor)
                        // Round specific corners depending on list index
                        .cornerRadius(index == 0 ? 16 : 0, corners: [.topLeft, .topRight])
                        .cornerRadius(index == sessions.prefix(10).count - 1 ? 16 : 0, corners: [.bottomLeft, .bottomRight])
                    }
                }
                .cornerRadius(16)
            }
        }
    }
    
    private var privacyDisclosureCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "hand.shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentHold)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("HIPAA & Privacy Safeguard")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    Text("Your data is stored strictly on-device inside an encrypted local sandbox. No data is transmitted to the cloud. You are in full control of clinical exports.")
                        .font(.system(.caption2, design: .default))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(2)
                }
            }
            
            Divider().background(Color.white.opacity(0.08))
            
            Button(role: .destructive, action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete All Local Data")
                }
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundColor(.accentRelease)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.accentRelease.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentRelease.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.rowGray)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .alert("Confirm Data Purge", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("Are you sure you want to permanently delete all grounding sessions and anxiety assessments? This action cannot be undone.")
        }
    }
    
    // MARK: - Report Helper
    
    private func updateReportURL() {
        reportURL = PDFExporter.generatePDF(sessions: sessions, assessments: assessments)
    }
    
    private func deleteAllData() {
        do {
            try modelContext.delete(model: GroundingSession.self)
            try modelContext.delete(model: GAD7Assessment.self)
            try modelContext.save()
            updateReportURL()
            print("[HistoryView] All SwiftData grounding session and assessment records successfully purged.")
        } catch {
            print("[HistoryView] Error purging database: \(error.localizedDescription)")
        }
    }
}

// MARK: - Premium Empty State Component

fileprivate struct PremiumEmptyState: View {
    let iconName: String
    let title: String
    let subtitle: String
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .foregroundColor(.hapticGlow.opacity(0.6))
                .shadow(color: .hapticGlow.opacity(0.2), radius: 6)
                .padding(.bottom, 4)
            
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text(subtitle)
                .font(.system(.caption, design: .default))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [GroundingSession.self, GAD7Assessment.self], inMemory: true)
}
