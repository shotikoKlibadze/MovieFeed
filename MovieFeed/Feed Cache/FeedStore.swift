//
//  FeedStore.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 14.10.22.
//

import Foundation

public protocol FeedStore {
    
    typealias DelitionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DelitionCompletion)
    func insertItems(items: [FeedItem], date: Date, completion: @escaping InsertionCompletion)
}
