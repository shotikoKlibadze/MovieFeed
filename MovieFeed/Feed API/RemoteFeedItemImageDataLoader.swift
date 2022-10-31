//
//  RemoteFeedItemImageDataLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 31.10.22.
//

import Foundation

struct HTTPClientTaskWrapper: FeedItemImageDataLoaderTask {
    
    let wrapped: URLSessionTask
    
    func cancel() {
        wrapped.cancel()
    }
}

public final class RemoteFeedItemImageDataLoader: FeedItemImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum ImageError: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedItemImageDataLoaderTask {
        let task = client.get(from: url) { result in
            switch result {
            case .success((let data, let response)):
                let isValidResponse = response.isOK && !data.isEmpty
                isValidResponse ? completion(.success(data)) : completion(.failure(ImageError.invalidData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return HTTPClientTaskWrapper(wrapped: (task as! URLSessionTaskWrapper).wrapped)
    }
}

private extension HTTPURLResponse {
    var isOK: Bool {
        return statusCode == 200
    }
}
