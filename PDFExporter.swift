//
//  PDFExporter.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Programmatic counselor-ready PDF compiler using ImageRenderer.
//

import SwiftUI

/// A view representing the standard layout format of the PDF clinical report.
@MainActor
public struct ClinicalReportView: View {
    
    /// The session logs to document.
    let sessions: [GroundingSession]
    
    /// The clinical GAD-7 assessments to document.
    let assessments: [GAD7Assessment]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Document Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calmpal Counselor Report")
                        .font(.title)
                        .bold()
                    Text("Personal Grounding & Anxiety Metric Tracking")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("CONFIDENTIAL")
                    .font(.system(.caption, design: .rounded).bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(6)
            }
            
            Divider()
            
            // Section 1: Grounding Summary
            VStack(alignment: .leading, spacing: 10) {
                Text("Grounding Activity Summary (Last 30 Days)")
                    .font(.headline)
                    .foregroundColor(.black)
                
                let totalDuration = sessions.reduce(0.0) { $0 + $1.duration }
                let avgPressure = sessions.isEmpty ? 0.0 : sessions.reduce(0.0) { $0 + Double($1.averagePressure) } / Double(sessions.count)
                
                HStack(spacing: 40) {
                    ReportMetricBlock(label: "Total Sessions", value: "\(sessions.count)")
                    ReportMetricBlock(label: "Mindful Time", value: "\(Int(totalDuration / 60.0)) min")
                    ReportMetricBlock(label: "Avg Force Target", value: String(format: "%.1f%%", avgPressure * 100.0))
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Section 2: GAD-7 Trends
            VStack(alignment: .leading, spacing: 10) {
                Text("GAD-7 Anxiety Check-ins")
                    .font(.headline)
                    .foregroundColor(.black)
                
                if assessments.isEmpty {
                    Text("No standardized check-ins recorded.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    VStack(spacing: 12) {
                        ForEach(assessments.prefix(4)) { checkIn in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(checkIn.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("Score: \(checkIn.score)/21")
                                        .font(.subheadline)
                                        .bold()
                                    Text("(\(checkIn.severityDescription))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                if !checkIn.notes.isEmpty {
                                    Text("Notes: \(checkIn.notes)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.02))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Section 3: Grounding Logs
            VStack(alignment: .leading, spacing: 10) {
                Text("Grounding Session Details")
                    .font(.headline)
                    .foregroundColor(.black)
                
                if sessions.isEmpty {
                    Text("No grounding sessions logged.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    VStack(spacing: 8) {
                        ForEach(sessions.prefix(6)) { session in
                            HStack {
                                Text(session.date.formatted(date: .numeric, time: .omitted))
                                    .font(.subheadline)
                                Text(session.protocolType)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(Int(session.duration)) sec")
                                    .font(.subheadline)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Divider()
            
            // Footer Legal
            VStack(spacing: 4) {
                Text("This report is exported from Calmpal. Data is stored strictly on-device in a local SwiftData sandbox, ensuring privacy compliance.")
                Text("DISCLAIMER: The clinical data and scores presented in this document are screening indicators and do not constitute a medical diagnosis or treatment plan. Consult a qualified clinical professional for diagnostics.")
            }
            .font(.system(size: 8))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
        .padding(36)
        .frame(width: 612, height: 792) // Strict standard Letter page size
        .background(Color.white)
        .foregroundColor(.black)
    }
}

fileprivate struct ReportMetricBlock: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.black)
        }
    }
}

// MARK: - PDFExporter Utility

/// Helper class that compiles standard PDF sheets from SwiftData results.
@MainActor
public final class PDFExporter {
    
    /// Renders the report layout to a temporary PDF file and returns its URL.
    /// - Parameters:
    ///   - sessions: List of GroundingSession records.
    ///   - assessments: List of GAD7Assessment records.
    /// - Returns: A local file URL pointing to the temporary PDF report, or nil if creation failed.
    public static func generatePDF(sessions: [GroundingSession], assessments: [GAD7Assessment]) -> URL? {
        let report = ClinicalReportView(sessions: sessions, assessments: assessments)
        let renderer = ImageRenderer(content: report)
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let pdfURL = tempDirectory.appendingPathComponent("Calmpal_Practitioner_Report.pdf")
        
        // Remove prior exports to prevent cache conflicts
        try? fileManager.removeItem(at: pdfURL)
        
        renderer.render { size, context in
            var mediaBox = CGRect(origin: .zero, size: CGSize(width: 612, height: 792))
            
            guard let pdfContext = CGContext(pdfURL as CFURL, mediaBox: &mediaBox, nil) else {
                print("[PDFExporter] Failed to create CGContext for PDF compilation.")
                return
            }
            
            pdfContext.beginPDFPage(nil)
            // Execute the draw commands on the PDF CoreGraphics context
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        return pdfURL
    }
}
