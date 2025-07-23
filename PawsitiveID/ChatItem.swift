//
//  ChatItem.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/23/25.
//

import Foundation

struct ChatItem: Codable {
    let id: String
    let message: String
    /** Type is "FOUND" or "LOST" */
    let type: String
    let post_id: String
}
