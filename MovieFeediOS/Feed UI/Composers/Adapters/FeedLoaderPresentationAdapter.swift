//
//  FeedLoaderPresentationAdapter.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 28.10.22.
//

import Foundation
import MovieFeed

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result{
            case .success(let items):
                self?.presenter?.didFinishLoadingFeed(with: items)
            case .failure(let error):
                self?.presenter?.didFinisLoadingFeed(with: error)
            }
        }
    }
}
