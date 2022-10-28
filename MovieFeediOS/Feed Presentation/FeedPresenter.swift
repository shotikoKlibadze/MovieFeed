//
//  FeedPresenter.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 26.10.22.
//

import Foundation
import MovieFeed

protocol FeedView {
    func display(model: FeedViewModel)
}

protocol FeedLoadingView {
    func display(model: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(model: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

final class FeedPresenter {

    let feedView: FeedView
    let loadingView: FeedLoadingView
    var errorView: FeedErrorView?
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
    }
    
    private var feedLoaderError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error Message displayed when cannot load from server")
    }
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        errorView?.display(model:.noError)
        loadingView.display(model: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with items: [FeedItem]) {
        feedView.display(model: FeedViewModel(items: items))
        loadingView.display(model: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinisLoadingFeed(with error: Error) {
        errorView?.display(model: .error(message: feedLoaderError))
        loadingView.display(model: FeedLoadingViewModel(isLoading: false))
    }

}
