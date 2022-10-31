//
//  LocalFeedItemImageDataStore.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 31.10.22.
//

import Foundation

struct MOCKCoreDataImageLoaderTaskWrapper: FeedItemImageDataLoaderTask {
    
    let data: Data?
    
    func cancel() {
        
    }
    
}


public class LocalFeedItemImageDataStore: FeedItemImageDataLoader {
   
    
    public let store: FeedItemImageDataStore
    
    public init(store: FeedItemImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedItemImageDataLoaderTask {
        store.retreive(dataForURL: url) { result in
            switch result {
            case .success(let data):
                completion(.success(data!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return MOCKCoreDataImageLoaderTaskWrapper(data: nil)
    }
    
    

    
    
}
