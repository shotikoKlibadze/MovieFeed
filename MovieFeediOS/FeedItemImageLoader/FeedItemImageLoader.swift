//
//  FeedItemImageLoader.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import Foundation

public protocol FeedItemImageDataLoaderTask {
    func cancel()
}

public protocol FeedItemImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedItemImageDataLoaderTask
}
