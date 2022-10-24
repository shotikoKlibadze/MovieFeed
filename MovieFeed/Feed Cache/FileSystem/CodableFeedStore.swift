//
//  CodableFeedStore.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 19.10.22.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feedItems: [CodableFeedItem]
        let timeStamp: Date
        
        var localFeed: [LocalFeedItem] {
            return feedItems.map({$0.local})
        }
    }
    
    private struct CodableFeedItem: Codable {
        private let id: Int
        private let description: String?
        private let title: String?
        private let imageURL: String
        
        init(_ item: LocalFeedItem) {
            self.id = item.id
            self.description = item.description
            self.title = item.title
            self.imageURL = item.imageURL
        }
    
        var local: LocalFeedItem {
            return LocalFeedItem(id: id, description: description, title: title, imageURL: imageURL)
        }
    }
    
    private let storeURL: URL
    private let queue = DispatchQueue(label: "CodableFeedStorequeue", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.empty))
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.found(items: cache.localFeed, timeStamp: cache.timeStamp)))
            } catch {
                completion(.failure(error))
            }
        }
       
    }
    
    public func insertItems(items: [LocalFeedItem], date: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feedItems: items.map({CodableFeedItem($0)}), timeStamp: date)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
       
    }
    
    public func deleteCachedFeed(completion: @escaping DelitionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
