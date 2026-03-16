//
//  CategoriesView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct CategoriesView: View {
    
    @Environment(OccupationService.self) var service
    @Environment(\.dismiss) var dismiss
    let onSelect: (String) -> Void

    private struct CategoryInfo: Identifiable {
        let slug: String
        let count: Int
        let avgExposure: Double
        var id: String { slug }
    }

    private var categories: [CategoryInfo] {
        let grouped = Dictionary(grouping: service.occupations, by: \.category)
        return grouped.map { slug, occupation in
            let avg = Double(occupation.map(\.exposure).reduce(0, +)) / Double(occupation.count)
            return CategoryInfo(slug: slug, count: occupation.count, avgExposure: avg)
        }
        .sorted { $0.slug < $1.slug }
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(categories) { cat in
                        Button {
                            onSelect(cat.slug)
                            dismiss()
                        } label: {
                            categoryTile(cat)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Browse by category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func categoryTile(_ cat: CategoryInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(categoryDisplayName(cat.slug))
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.primary)
            Text("\(cat.count) careers")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                Text(String(format: "%.1f", cat.avgExposure))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primary.opacity(0.08))
                            .frame(height: 3)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(riskColor(for: Int(cat.avgExposure.rounded())))
                            .frame(width: geo.size.width * CGFloat(cat.avgExposure) / 10, height: 3)
                    }
                }
                .frame(height: 3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
