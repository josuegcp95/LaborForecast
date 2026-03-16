import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesViewModel.self) var favorites
    @Environment(OccupationService.self) var service

    var body: some View {
        NavigationStack {
            Group {
                if favorites.savedSlugs.isEmpty {
                    emptyState
                } else {
                    populatedState
                }
            }
            .navigationTitle("Saved")
            .navigationDestination(for: Occupation.self) { occ in
                CareerDetailView(occupation: occ)
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
        List {
            Section {
                Text("\(favorites.savedOccupations.count) careers saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
            .listRowBackground(Color.clear)

            ForEach(favorites.savedOccupations) { occ in
                NavigationLink(value: occ) {
                    savedRow(occ)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        favorites.remove(occ.slug)
                    } label: {
                        Label("Remove", systemImage: "heart.slash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func savedRow(_ occ: Occupation) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(occ.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                Text("\(categoryDisplayName(occ.category)) · \(formatPay(occ.pay))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TierBadge(tier: occ.aiTier)
        }
        .padding(.vertical, 4)
    }
}
