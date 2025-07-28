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

let chatInitiator = [
    ChatItem(
        id: "0_1",
        message: "Test chat item. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.",
        post_id: "0",
        created_at: "2025-07-27 21:12:21"
    ),
    ChatItem(
        id: "0_2",
        message: "Test chat item 2. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.",
        post_id: "0",
        created_at: "2025-07-27 18:12:21"
    )
]
