//
//  FeedItemsMapper.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.09.22.
//


import Foundation


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
