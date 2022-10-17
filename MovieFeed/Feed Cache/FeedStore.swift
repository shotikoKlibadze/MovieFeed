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
    typealias RetrievalCompletion = (Result<[FeedItem], Error>) -> Void
    
    func deleteCachedFeed(completion: @escaping DelitionCompletion)
    func insertItems(items: [LocalFeedItem], date: Date, completion: @escaping InsertionCompletion)
    func retrieveItems(completion: @escaping RetrievalCompletion)
}
