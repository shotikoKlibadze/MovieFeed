//
//  RemoteFeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader  {
    
    private let client: HTTPClient
    private let url : URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public typealias Result = LoadFeedResult
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                let result = FeedItemsMapper.map(data: data, response: response)
                completion(result)
                break
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }

}
