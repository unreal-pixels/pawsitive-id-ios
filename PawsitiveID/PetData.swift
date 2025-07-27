//
//  PetData.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/19/25.
//

import Foundation

enum AnimalType {
    case Dog
    case Cat
    case Rabbit
    case Bird
    case Other
}

struct PetDataApi: Codable {
    let status: String
    let data: [PetData]
}

struct PetDataApiSingle: Codable {
    let status: String
    let data: PetData
}

struct PetData: Codable, Identifiable {
    let id: String
    var name: String
    /** Post Type is "FOUND" or "LOST" */
    var post_type: String
    /** Animal Type  is "CAT" or  "DOG" or "'RABBIT" or "BIRD" or "OTHER" */
    var animal_type: String
    var description: String
    var last_seen_date: String
    var last_seen_long: String
    var last_seen_lat: String
    var post_by_name: String
    var post_by_phone: String?
    var post_by_email: String?
    let created_at: String
    var reunited: Bool
    var images: [String]
    var chats: [ChatItem]
}

let petInitiator = PetData(
    id: "0",
    name: "Test",
    post_type: "FOUND",
    animal_type: "CAT",
    description: "Pretty cat",
    last_seen_date: "2025-07-24",
    last_seen_long: "-122.009178",
    last_seen_lat: "37.351884",
    post_by_name: "Test user",
    post_by_phone: "415-555-1234",
    post_by_email: "test@example.com",
    created_at: "2025-07-23 12:41:05",
    reunited: false,
    images: [],
    chats: []
)
