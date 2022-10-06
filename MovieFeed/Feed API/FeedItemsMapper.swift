//
//  FeedItemsMapper.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.09.22.
//


import Foundation

final class FeedItemsMapper {
    
    private struct Root: Codable {
        let items: [Item]
        
        enum CodingKeys: String, CodingKey {
            case items = "results"
        }
        
        var feed: [FeedItem] {
            return items.map({$0.item})
        }
    }

    public struct Item: Codable {
        
       let id: Int
       let description: String
       let title: String
       let image: String

        enum CodingKeys: String, CodingKey {
            case id
            case description = "overview"
            case title = "name"
            case image = "poster_path"
        }
        
        var item : FeedItem {
            return FeedItem(id: id, description: description, title: title, imageURL: image)
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(data: Data, response: HTTPURLResponse) -> LoadFeedResult {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        print(root.feed.count)
        return .success(root.feed)
    }
}

