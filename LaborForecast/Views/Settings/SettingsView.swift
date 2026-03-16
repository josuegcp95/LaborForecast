//
//  SettingsView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("Methodology", systemImage: "doc.text")
                    }

                    NavigationLink {
                        DataSourcesView()
                    } label: {
                        Label("Data sources", systemImage: "externaldrive")
                    }
                }
                
                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://www.termsfeed.com/live/a8d007e5-8b3c-4bd3-b6c3-18722d3dd42d")!)
                        .foregroundStyle(Color.LFGreen)
                    Link("Terms & Conditions", destination: URL(string: "https://www.termsfeed.com/live/ad62e2d5-6004-4395-9960-f7a9f106ff6a")!)
                        .foregroundStyle(Color.LFGreen)
                }

                Section("App") {
                    ShareLink(
                        item: URL(string: "https://apps.apple.com")!,
                        message: Text("Check your AI exposure risk with LaborForecast!")
                    ) {
                        Label("Share LaborForecast", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text("LaborForecast · Data: BLS OOH 2024–2034")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)
            }
        }
    }
}
