//
//  FeedItemsMapper.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.09.22.
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

final class FeedItemsMapper {
    
    private struct Root: Codable {
        let items: [RemoteFeedItem]
        
        enum CodingKeys: String, CodingKey {
            case items = "results"
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
