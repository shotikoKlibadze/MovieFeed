//
//  FeedItemPresentationAdapter.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 28.10.22.
//

import MovieFeed

final class FeedItemPresentationAdapter: FeedImageCellControllerDelegate {
    
    private let feedItem: FeedItem
    private weak var imageLoader: FeedItemImageDataLoader?
    var task: FeedItemImageDataLoaderTask?
    var presenter: FeedItemPresenter?
    
    init(feedItem: FeedItem, imageLoader: FeedItemImageDataLoader) {
        self.feedItem = feedItem
        self.imageLoader = imageLoader
    }
    
    private struct ImageTransformationError: Error {}
    
    
    func didRequestFeedItem() {
        presenter?.didStartLoadingImageData(for: feedItem)
        guard let url = URL(string: feedItem.imageURL) else { return }
        task = imageLoader?.loadImageData(from: url) { [ weak self] result in
            guard let self = self else { return }
            let data = try? result.get()
            self.presenter?.didFinishLoadingImageData(with: data, for: self.feedItem)
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
