//
//  CoreDataFeedStore.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.10.22.
//

import CoreData

final public class CoreDataFeedStore: FeedStore {
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    
    public func deleteCachedFeed(completion: @escaping DelitionCompletion) {
        perform { context in
            do {
                try ManagedCache.deleteCache(in: context)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insertItems(items: [LocalFeedItem], date: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timeStamp = date
                managedCache.feedItems = ManagedFeedItem.feedItems(from: items, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(items: cache.localFeed, timeStamp: cache.timeStamp!))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error: error))
            }
        }
    }
    
    private func perform(_ action: @escaping(NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }

}

extension CoreDataFeedStore {
    public func givesString() -> String? {
        return "i have been iniated"
    }
}
