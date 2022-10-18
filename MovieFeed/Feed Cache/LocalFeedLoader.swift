//
//  LocalFeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 14.10.22.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = (LoadFeedResult) -> Void
    
    public init (store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    //MARK: Saving
    
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

    private func cache(items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insertItems(items: items.toLocal(), date: currentDate(), completion: { [weak self] error in
            guard self != nil  else { return }
            completion(error)
        })
    }
    
    //MARK: Loading
    
    public func load(completion: @escaping LoadResult) {
        store.retrieveItems { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(error: let error):
                self.store.deleteCachedFeed(completion: { _ in})
                completion(.failure(error))
            case .found(feed: let feed, timeStamp: let timeStamp) where self.validate(timeStamp):
                completion(.success(feed.toModels()))
            case .found:
                self.store.deleteCachedFeed(completion: { _ in })
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    private var maxCacheAgeInDays : Int {
        return 7
    }
    
    private func validate(_ timeStamp: Date) -> Bool {
        guard let maxAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else { return false }
        return currentDate() < maxAge
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.imageURL)}
    }
}

private extension Array where Element == LocalFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.imageURL)}
    }
}
