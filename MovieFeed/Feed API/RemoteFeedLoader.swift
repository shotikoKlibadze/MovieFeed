//
//  RemoteFeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import Foundation

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
                let result = FeedItemsMapper.map(data: data, response: response)
                completion(result)
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}
