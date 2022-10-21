//
//  ManagedCache+CoreDataProperties.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.10.22.
//
//

import Foundation
import CoreData


extension ManagedCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }

    @NSManaged public var timeStamp: Date?
    @NSManaged public var feedItems: NSOrderedSet?

}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func deleteCache(in context: NSManagedObjectContext) throws {
       // try find(in: context).map(context.delete).map(context.save)
        
        try find(in: context).map({ cache in
            context.delete(cache)
        }).map({ _ in
            try context.save()
        })
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try deleteCache(in: context)
        return ManagedCache(context: context)
    }
    
    var localFeed: [LocalFeedItem] {
        return feedItems?.compactMap { ($0 as? ManagedFeedItem)?.local } ?? []
    }
}



// MARK: Generated accessors for feedItems
extension ManagedCache {

    @objc(insertObject:inFeedItemsAtIndex:)
    @NSManaged public func insertIntoFeedItems(_ value: ManagedFeedItem, at idx: Int)

    @objc(removeObjectFromFeedItemsAtIndex:)
    @NSManaged public func removeFromFeedItems(at idx: Int)

    @objc(insertFeedItems:atIndexes:)
    @NSManaged public func insertIntoFeedItems(_ values: [ManagedFeedItem], at indexes: NSIndexSet)

    @objc(removeFeedItemsAtIndexes:)
    @NSManaged public func removeFromFeedItems(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedItemsAtIndex:withObject:)
    @NSManaged public func replaceFeedItems(at idx: Int, with value: ManagedFeedItem)

    @objc(replaceFeedItemsAtIndexes:withFeedItems:)
    @NSManaged public func replaceFeedItems(at indexes: NSIndexSet, with values: [ManagedFeedItem])

    @objc(addFeedItemsObject:)
    @NSManaged public func addToFeedItems(_ value: ManagedFeedItem)

    @objc(removeFeedItemsObject:)
    @NSManaged public func removeFromFeedItems(_ value: ManagedFeedItem)

    @objc(addFeedItems:)
    @NSManaged public func addToFeedItems(_ values: NSOrderedSet)

    @objc(removeFeedItems:)
    @NSManaged public func removeFromFeedItems(_ values: NSOrderedSet)

}

extension ManagedCache : Identifiable {

}
