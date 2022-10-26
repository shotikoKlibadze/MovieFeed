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
        let feedViewModel = FeedViewModel(feedLodaer: feedLoader)
        let refreshController = RefreshViewController(viewModel: feedViewModel)
        let feedControler = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = { [weak feedControler] feed in
            feedControler?.tableModels = feed.map({ model in
                let viewModel = FeedItemViewModel(feedItem: model, imageLoader: imageLoader)
                return FeedItemCellController(viewModel: viewModel)
            })
        }
        return feedControler
    }
    
}
