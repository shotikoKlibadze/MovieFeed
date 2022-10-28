//
//  MainQueueDispatchDecorator.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 28.10.22.
//

import UIKit
import MovieFeed

final class MainQueueDispatchDecorator<T> {
    
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }
        completion()
    }
    
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
}

extension MainQueueDispatchDecorator: FeedItemImageDataLoader where T == FeedItemImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedItemImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
