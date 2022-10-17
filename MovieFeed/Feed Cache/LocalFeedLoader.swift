//
//  LocalFeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 14.10.22.
//

import Foundation

public final class LocalFeedLoader {
    
    let store: FeedStore
    let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = (Result<[FeedItem], Error>) -> Void
    
    public init (store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cachedDelitionError = error {
                completion(cachedDelitionError)
            } else {
                self.cache(items: items, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping LoadResult) {
        store.retrieveItems(completion: completion)
    }
    
    private func cache(items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insertItems(items: items.toLocal(), date: currentDate(), completion: { [weak self] error in
            guard self != nil  else { return }
            completion(error)
        })
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.imageURL)}
    }
}
