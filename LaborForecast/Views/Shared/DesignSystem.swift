//
//  DesignSystem.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let LFDarkBG    = Color(hex: "#090B10")
    static let LFLightBG   = Color(hex: "#F5F2EC")
    static let LFGreen     = Color(hex: "#22C55E")

    static let riskMinimal  = Color(hex: "#22C55E")
    static let riskLow      = Color(hex: "#5BD87C")
    static let riskModerate = Color(hex: "#EAB308")
    static let riskHigh     = Color(hex: "#F97316")
    static let riskVeryHigh = Color(hex: "#DC2626")
}

// MARK: - Risk Helpers

func riskColor(for score: Int) -> Color {
    switch score {
    case 0...1: return .riskMinimal
    case 2...3: return .riskLow
    case 4...5: return .riskModerate
    case 6...7: return .riskHigh
    default:    return .riskVeryHigh
    }
}

func tierColor(for tier: String) -> Color {
    switch tier {
    case "minimal":  return .riskMinimal
    case "low":      return .riskLow
    case "moderate": return .riskModerate
    case "high":     return .riskHigh
    default:         return .riskVeryHigh
    }
}

func tierLabel(for tier: String) -> String {
    switch tier {
    case "minimal":  return "Minimal"
    case "low":      return "Low"
    case "moderate": return "Moderate"
    case "high":     return "High"
    default:         return "Very High"
    }
}

// MARK: - Formatting Helpers

func formatPay(_ pay: Int?) -> String {
    guard let pay else { return "No data" }
    let k = pay / 1000
    return "$\(k)k"
}

func formatJobs(_ jobs: Int?) -> String {
    guard let jobs else { return "No data" }
    if jobs >= 1_000_000 {
        return String(format: "%.1fM", Double(jobs) / 1_000_000)
    } else if jobs >= 1_000 {
        return String(format: "%.0fK", Double(jobs) / 1_000)
    }
    return "\(jobs)"
}

func formatOutlook(_ outlook: Double?) -> String {
    guard let outlook else { return "No data" }
    let sign = outlook > 0 ? "+" : ""
    return "\(sign)\(Int(outlook))%"
}

func categoryDisplayName(_ slug: String) -> String {
    slug
        .replacingOccurrences(of: "-and-", with: " & ")
        .replacingOccurrences(of: "-", with: " ")
        .split(separator: " ")
        .map { word -> String in
            let s = String(word)
            // Keep small connector words lowercase unless first word
            return s.prefix(1).uppercased() + s.dropFirst()
        }
        .joined(separator: " ")
}

// MARK: - Risk Tier Badge

struct TierBadge: View {
    let tier: String

    var body: some View {
        Text(tierLabel(for: tier))
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tierColor(for: tier).opacity(0.18))
            .foregroundStyle(tierColor(for: tier))
            .clipShape(Capsule())
    }
}
