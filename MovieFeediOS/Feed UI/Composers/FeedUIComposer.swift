//
//  FeedUIComposer.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import MovieFeed

public final class FeedUIComposer {
    
    private init() {}
    
    //MARK: - MVP Pattern -
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLodaer: feedLoader)
        let refreshController = RefreshViewController(presenter: presenter)
        let feedControler = FeedViewController(refreshController: refreshController)
        let feedViewAdapter = FeedViewAdapter(controller: feedControler, imageLoader: imageLoader)
        
        presenter.feedLoadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = feedViewAdapter
        
        return feedControler
    }
    
    //MARK: - MVVM Pattern -
//    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemImageDataLoader) -> FeedViewController {
//        let feedViewModel = FeedViewModel(feedLodaer: feedLoader)
//        let refreshController = RefreshViewController(viewModel: feedViewModel)
//        let feedControler = FeedViewController(refreshController: refreshController)
//        feedViewModel.onFeedLoad = { [weak feedControler] feed in
//            feedControler?.tableModels = feed.map({ model in
//                let viewModel = FeedItemViewModel(feedItem: model, imageLoader: imageLoader)
//                return FeedItemCellController(viewModel: viewModel)
//            })
//        }
//        return feedControler
//    }
}

private final class WeakRefVirtualProxy<T: AnyObject>{
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

private final class FeedViewAdapter: FeedView {
    
    weak var controller: FeedViewController?
    let imageLoader: FeedItemImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedItemImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedItem]) {
        controller?.tableModels = feed.map({ feedItem in
            let viewModel = FeedItemViewModel(feedItem: feedItem, imageLoader: imageLoader)
            return FeedItemCellController(viewModel: viewModel)
        })
    }

}
