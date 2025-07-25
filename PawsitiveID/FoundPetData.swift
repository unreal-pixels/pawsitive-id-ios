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

struct FoundPetDataApiSingle: Codable {
    let status: String
    let data: FoundPetData
}

struct FoundPetData: Codable, Identifiable {
    let id: String
    let name: String
    /** Animal Type  is "CAT" or  "DOG" or "'RABBIT" or "BIRD" or "OTHER" */
    let animal_type: String
    let description: String
    let last_seen_date: String
    let last_seen_long: String
    let last_seen_lat: String
    let found_by_name: String
    let found_by_phone: String?
    let found_by_email: String?
    let created_at: String
    let photo: String?
    let chats: [ChatItem]
}

let foundPetInitiator = FoundPetData(
    id: "0",
    name: "Test",
    animal_type: "CAT",
    description: "Pretty cat",
    last_seen_date: "2025-07-24",
    last_seen_long: "-122.009178",
    last_seen_lat: "37.351884",
    found_by_name: "Test user",
    found_by_phone: "415-555-1234",
    found_by_email: "test@example.com",
    created_at: "2025-07-23 12:41:05",
    photo: nil,
    chats: []
)
