//
//  FeedStore.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 14.10.22.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case failure(error: Error)
    case found(items: [LocalFeedItem], timeStamp: Date)
    case empty
}

public protocol FeedStore {
    
    typealias DelitionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropraite thread
    func deleteCachedFeed(completion: @escaping DelitionCompletion)
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropraite thread
    func insertItems(items: [LocalFeedItem], date: Date, completion: @escaping InsertionCompletion)
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropraite thread
    func retrieve(completion: @escaping RetrievalCompletion)
}
