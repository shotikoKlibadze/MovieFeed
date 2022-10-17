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
                do {
                    let items = try FeedItemsMapper.map(data: data, response: response)
                    completion(.success(items.toModels()))

                } catch (let error) {
                    completion(.failure(error))
                }
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }

}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map({FeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.image ?? "")})
    }
}
