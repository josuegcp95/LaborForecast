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

                Section("App") {
                    ShareLink(
                        item: URL(string: "https://apps.apple.com")!,
                        message: Text("Check your AI exposure risk with OccForecast!")
                    ) {
                        Label("Share OccForecast", systemImage: "square.and.arrow.up")
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
                Text("OccForecast v1.0.0 · Data: BLS OOH 2024–2034")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)
            }
        }
    }
}
