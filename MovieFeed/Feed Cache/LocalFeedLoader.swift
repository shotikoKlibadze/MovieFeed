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
    
    public init (store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (Error?) -> Void ) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cachedDelitionError = error {
                completion(cachedDelitionError)
            } else {
                self.cache(items: items, with: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insertItems(items: items, date: currentDate(), completion: { [weak self] error in
            guard self != nil  else { return }
            completion(error)
        })
    }
}
