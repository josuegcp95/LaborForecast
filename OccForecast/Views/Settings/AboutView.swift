//
//  AboutView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What is AI Exposure?")
                        .font(.headline)
                    Text("AI exposure measures how likely an occupation's core tasks are to be automated, augmented, or restructured by artificial intelligence over the next decade. It does not predict job elimination — many high-exposure jobs will transform rather than disappear.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Scoring Rubric (0–10)")
                        .font(.headline)

                    rubricRow(range: "0–1", label: "Minimal", description: "Tasks require physical dexterity, complex social interaction, or deep contextual judgment that current AI cannot replicate.")
                    rubricRow(range: "2–3", label: "Low", description: "Some routine tasks are automatable but core work requires human judgment, creativity, or in-person presence.")
                    rubricRow(range: "4–5", label: "Moderate", description: "AI tools augment productivity significantly. Entry-level roles most affected. Senior roles retain value.")
                    rubricRow(range: "6–7", label: "High", description: "Majority of tasks are data or language processing. AI handles a growing share of core deliverables.")
                    rubricRow(range: "8–10", label: "Very High", description: "Primary output is information, analysis, or content that AI can produce faster and cheaper. Structural workforce change likely.")
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Vintage")
                        .font(.headline)
                    Text("Employment, salary, and outlook figures are from the Bureau of Labor Statistics Occupational Outlook Handbook, 2024–2034 projections. AI exposure scores were generated using Gemini Flash with a structured 6-factor rubric.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Methodology")
        .navigationBarTitleDisplayMode(.large)
    }

    private func rubricRow(range: String, label: String, description: String) -> some View {
        let firstDigit = Int(String(range.prefix(1))) ?? 0
        return HStack(alignment: .top, spacing: 12) {
            Text(range)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(riskColor(for: firstDigit))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
