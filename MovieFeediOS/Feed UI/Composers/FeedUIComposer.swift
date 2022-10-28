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
        
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemImageDataLoader) -> FeedViewController {
        //1
        let feedLoader = MainQueueDispatchDecorator(decoratee:feedLoader)
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader )
        //3
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        let imageLoader = MainQueueDispatchDecorator(decoratee: imageLoader)
        let feedView =  FeedViewAdapter(controller: feedController,
                                        imageLoader: imageLoader)
        //3
        let feedLoadingView = WeakRefVirtualProxy(feedController)
        let presenter = FeedPresenter(feedView: feedView,
                                      loadingView: feedLoadingView )
        presentationAdapter.presenter = presenter
        //4
        return feedController
    }

}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        let feedControler = storyBoard.instantiateInitialViewController() as! FeedViewController
        feedControler.delegate = delegate
        feedControler.title = title
        return feedControler
    }
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
