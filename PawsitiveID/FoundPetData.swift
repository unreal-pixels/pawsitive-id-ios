//
//  FoundPetData.swift.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/19/25.
//

import Foundation

struct FoundPetDataApi: Codable {
    let status: String
    let data: [FoundPetData]
}

struct FoundPetData: Codable, Identifiable {
    let id: String
    let name: String
    let animal_type: String
    let description: String
    let last_seen_date: String
    let last_seen_long: String
    let last_seen_lat: String
    let found_by_name: String
    let found_by_phone: String
    let found_by_email: String
}
