//
//  FeedPresenter.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 26.10.22.
//

import Foundation
import MovieFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedItem])
}

final class FeedPresenter {

    typealias Observer<T> = (T) -> Void

    private let feedLoader: FeedLoader

    var feedView: FeedView?
    var feedLoadingView: FeedLoadingView?

    init(feedLodaer: FeedLoader) {
        self.feedLoader = feedLodaer
    }

    func loadFeed() {
        feedLoadingView?.display(isLoading: true)
        feedLoader.load(completion: { [weak self] result in
            if let items = try? result.get() {
                self?.feedView?.display(feed: items)
            }
            self?.feedLoadingView?.display(isLoading: false)
        })
    }
}
