//
//  FeedViewAdapter.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 28.10.22.
//

import MovieFeed

final class FeedViewAdapter: FeedView {
    
    weak var controller: FeedViewController?
    let imageLoader: FeedItemImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedItemImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(model: FeedViewModel) {
        controller?.tableModels = model.items.map({ feedItem in
            let presentationAdapter = FeedItemPresentationAdapter(feedItem: feedItem, imageLoader: imageLoader)
            let cellController = FeedItemCellController(delegate: presentationAdapter)
            let feedItemPresenter = FeedItemPresenter(view: cellController)
            presentationAdapter.presenter = feedItemPresenter
            return cellController
        })
    }
}
