//
//  ChatItem.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/23/25.
//

import Foundation

struct ChatItem: Codable {
    let id: String
    var message: String
    var post_id: String
    let created_at: String
}
