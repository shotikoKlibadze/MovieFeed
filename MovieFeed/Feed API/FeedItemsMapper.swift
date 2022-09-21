//
//  FeedItemsMapper.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.09.22.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Codable {
        let items : [Item]
        
        var feed: [FeedItem] {
            return items.map({$0.item})
        }
    }

    public struct Item: Codable {
       let id: UUID
       let description: String?
       let location: String?
       let image: URL
        
        var item : FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static var OK_200: Int { return 200}
    
    static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}

