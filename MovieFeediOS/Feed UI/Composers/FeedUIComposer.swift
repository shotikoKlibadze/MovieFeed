//
//  FeedUIComposer.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import MovieFeed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemImageDataLoader) -> FeedViewController {
        let refreshController = RefreshViewController(feedLodaer: feedLoader)
        let feedControler = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak feedControler] feed in
            feedControler?.tableModels = feed.map({ model in
                FeedItemCellController(feedItem: model, imageLoader: imageLoader)
            })
        }
        return feedControler
    }
    
}
