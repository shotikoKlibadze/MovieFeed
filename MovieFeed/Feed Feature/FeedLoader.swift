//
//  FeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import Foundation

public protocol FeedLoader {
    
    typealias Result = Swift.Result<[FeedItem],Error>
    
    func load(completion: @escaping (Result) -> Void)
}
