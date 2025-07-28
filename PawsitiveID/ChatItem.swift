//
//  ChatItem.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/23/25.
//

import Foundation

struct ChatItemApiSingle: Codable {
    let status: String
    let data: ChatItem
}

struct ChatItem: Codable, Hashable {
    let id: String
    var message: String
    var post_id: String
    let created_at: String
}
