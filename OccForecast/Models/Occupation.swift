//
//  Occupation.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import Foundation

struct Occupation: Codable, Identifiable, Hashable {
    let slug: String
    let title: String
    let category: String
    let socCode: String
    let exposure: Int
    let aiTier: String
    let aiReason: String
    let pay: Int?
    let jobs: Int?
    let outlook: Double?
    let outlookDesc: String
    let education: String
    let saferAlts: [String]
    let url: String

    var id: String { slug }
}
