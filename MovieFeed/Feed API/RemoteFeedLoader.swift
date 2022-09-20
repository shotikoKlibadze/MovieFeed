//
//  RemoteFeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url : URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200 , let root = try? JSONDecoder().decode(Root.self, from: data)  {
                    completion(.success(root.items.map{$0.item}))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
    
}

private struct Root: Codable {
    let items : [Item]
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
