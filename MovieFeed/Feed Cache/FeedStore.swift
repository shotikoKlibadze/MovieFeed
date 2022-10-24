//
//  FeedStore.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 14.10.22.
//

import Foundation

public typealias RetrieveCachedFeedResult = Result<CachedFeed, Error>

public enum CachedFeed {
    case empty
    case found(items: [LocalFeedItem], timeStamp: Date)
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
