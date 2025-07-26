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
    var name: String
    /** Animal Type  is "CAT" or  "DOG" or "'RABBIT" or "BIRD" or "OTHER" */
    var animal_type: String
    var description: String
    var last_seen_date: String
    var last_seen_long: String
    var last_seen_lat: String
    var found_by_name: String
    var found_by_phone: String?
    var found_by_email: String?
    let created_at: String
    var photo: String?
    var chats: [ChatItem]
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
