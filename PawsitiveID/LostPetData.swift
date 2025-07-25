//
//  LostPetData.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/23/25.
//

import Foundation

struct LostPetDataApi: Codable {
    let status: String
    let data: [LostPetData]
}

struct LostPetDataApiSingle: Codable {
    let status: String
    let data: LostPetData
}

struct LostPetData: Codable, Identifiable {
    let id: String
    let name: String
    /** Animal Type  is "CAT" or  "DOG" or "'RABBIT" or "BIRD" or "OTHER" */
    let animal_type: String
    let description: String
    let last_seen_date: String
    let last_seen_long: String
    let last_seen_lat: String
    let owner_name: String
    let owner_phone: String
    let owner_email: String
    let created_at: String
    let photo: String
    let chats: [ChatItem]
}
