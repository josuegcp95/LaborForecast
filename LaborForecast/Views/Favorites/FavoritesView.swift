//
//  FavoritesView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct FavoritesView: View {
    
    @Environment(OccupationService.self) var service
    @Environment(FavoritesViewModel.self) var favorites

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Pinned title — lives outside the List so it never scrolls away
                HStack {
                    Text("Saved")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                if favorites.savedSlugs.isEmpty {
                    emptyState
                } else {
                    populatedState
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !favorites.savedSlugs.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
            .navigationDestination(for: Occupation.self) { occupation in
                CareerDetailView(occupation: occupation)
            }
        }
    }
    
    // MARK: - Empty
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart")
                .font(.system(size: 56))
                .foregroundStyle(.secondary.opacity(0.45))
            Text("No saved careers")
                .font(.headline)
            Text("Tap the bookmark icon on any career to save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
    
    // MARK: - Populated
    
    private var populatedState: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(favorites.savedOccupations.count) careers saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 8)
            
            List {
                ForEach(favorites.savedOccupations) { occupation in
                    NavigationLink(value: occupation) {
                        savedRow(occupation)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            favorites.remove(occupation.slug)
                        } label: {
                            Label("Remove", systemImage: "heart.slash")
                        }
                    }
                }
                .onMove { source, destination in
                    favorites.move(from: source, to: destination)
                }
            }
            .listStyle(.plain)
            .contentMargins(.bottom, 16, for: .scrollContent)
        }
    }
    
    private func savedRow(_ occupation: Occupation) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(occupation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                Text("\(categoryDisplayName(occupation.category)) · \(formatPay(occupation.pay))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TierBadge(tier: occupation.aiTier)
        }
        .padding(.vertical, 4)
    }
}
