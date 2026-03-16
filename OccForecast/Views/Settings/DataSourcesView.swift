//
//  DataSourcesView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct DataSourcesView: View {
    var body: some View {
        List {
            Section("Labor Market Data") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bureau of Labor Statistics")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Occupational Outlook Handbook, 2024–2034 projections. Employment counts, median salaries, education requirements, and 10-year growth projections.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Link("bls.gov/ooh", destination: URL(string: "https://www.bls.gov/ooh")!)
                        .font(.caption)
                        .foregroundStyle(Color.LFGreen)
                }
                .padding(.vertical, 4)
            }

            Section("AI Exposure Scoring") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Gemini Flash — Structured Rubric")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("AI exposure scores (0–10) were generated using Google Gemini Flash with a 6-factor structured rubric evaluating task routineness, data dependency, language processing intensity, creative requirement, physical presence need, and social judgment complexity.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Coverage") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("342 BLS-tracked occupations")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("All major US occupational groups covered. SOC codes provided where available. Military occupations included with limited salary data.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Data Sources")
        .navigationBarTitleDisplayMode(.large)
    }
}
