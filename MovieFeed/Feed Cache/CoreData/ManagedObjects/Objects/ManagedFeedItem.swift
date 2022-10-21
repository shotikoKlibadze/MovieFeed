//
//  ManagedFeedItem+CoreDataProperties.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.10.22.
//
//

import Foundation
import CoreData


extension ManagedFeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeedItem> {
        return NSFetchRequest<ManagedFeedItem>(entityName: "ManagedFeedItem")
    }

    @NSManaged public var id: Int32
    @NSManaged public var itemDescription: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var cache: ManagedCache?

}

extension ManagedFeedItem {
   
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedItem? {
        let request = NSFetchRequest<ManagedFeedItem>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedItem.imageURL), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func feedItems(from localItems: [LocalFeedItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        let items = NSOrderedSet(array: localItems.map({ local in
            let managed = ManagedFeedItem(context: context)
            managed.id = Int32(local.id)
            managed.itemDescription = local.description
            managed.title = local.title
            managed.imageURL = local.imageURL
            return managed
        }))
        context.userInfo.removeAllObjects()
        return items
    }
    
    var local: LocalFeedItem {
        return LocalFeedItem(id: Int(id), description: itemDescription, title: title, imageURL: imageURL ?? "")
    }
    
}

extension ManagedFeedItem : Identifiable {

}
