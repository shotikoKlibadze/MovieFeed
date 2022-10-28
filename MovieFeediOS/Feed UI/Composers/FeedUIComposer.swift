//
//  FeedUIComposer.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import MovieFeed
import UIKit

public final class FeedUIComposer {
    
    private init() {}
    
    //MARK: - MVP Pattern -
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader)
    
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        let feedControler = storyBoard.instantiateInitialViewController() as! FeedViewController
        
        feedControler.delegate = presentationAdapter
    
        let presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedControler,
                                                                imageLoader: imageLoader),
                                      feedLoadingView: WeakRefVirtualProxy(feedControler))
        
        presentationAdapter.presenter = presenter
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
    func display(model: FeedLoadingViewModel) {
        object?.display(model: model)
    }
}
