//
//  RemoteFeedItem.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.10.22.
//

import Foundation

struct RemoteFeedItem: Codable {
   let id: Int
   let description: String
   let title: String
   let image: String?

    enum CodingKeys: String, CodingKey {
        case id
        case description = "overview"
        case title = "name"
        case image = "poster_path"
    }
}
