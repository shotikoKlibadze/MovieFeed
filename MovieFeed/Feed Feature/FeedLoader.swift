//
//  FeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
