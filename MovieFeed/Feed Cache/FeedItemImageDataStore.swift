//
//  FeedItemImageDataStore.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 31.10.22.
//

import Foundation

public protocol FeedItemImageDataStore {
    func insert(_ data: Data, for url: URL, completion: @escaping (Result<Void,Error>) -> Void)
    func retreive(dataForURL url: URL, completion: @escaping (Result<Data?,Error>) -> Void)
}
