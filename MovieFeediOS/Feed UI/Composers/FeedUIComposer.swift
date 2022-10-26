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
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader)
        let refreshController = RefreshViewController(delegate: presentationAdapter)
        let feedControler = FeedViewController(refreshController: refreshController)
        let presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedControler,
                                                                imageLoader: imageLoader),
                                      feedLoadingView: WeakRefVirtualProxy(refreshController))
        
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

private final class FeedViewAdapter: FeedView {
    
    weak var controller: FeedViewController?
    let imageLoader: FeedItemImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedItemImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(model: FeedItemsViewModel) {
        controller?.tableModels = model.items.map({ feedItem in
            let viewModel = FeedItemViewModel(feedItem: feedItem, imageLoader: imageLoader)
            return FeedItemCellController(viewModel: viewModel)
        })
    }

}

private final class FeedLoaderPresentationAdapter: RefreshViewControllerDelegate {
    
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
