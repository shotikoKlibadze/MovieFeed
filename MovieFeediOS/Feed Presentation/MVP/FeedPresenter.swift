//
//  FeedPresenter.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 26.10.22.
//

import Foundation
import MovieFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
   // let lastUpdated: String
}

protocol FeedLoadingView {
    func display(model: FeedLoadingViewModel)
}

struct FeedItemsViewModel {
    let items: [FeedItem]
}

protocol FeedView {
    func display(model: FeedItemsViewModel)
}

final class FeedPresenter {

    let feedView: FeedView
    let feedLoadingView: FeedLoadingView
    
    init(feedView: FeedView, feedLoadingView: FeedLoadingView) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
    }

    func didStartLoadingFeed() {
        feedLoadingView.display(model: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with items: [FeedItem]) {
        feedView.display(model: FeedItemsViewModel(items: items))
        feedLoadingView.display(model: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinisLoadingFeed(with error: Error) {
        feedLoadingView.display(model: FeedLoadingViewModel(isLoading: false))
    }

}
