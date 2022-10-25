//
//  RefreshViewController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

final class RefreshViewController: NSObject {
    
    lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedLoader: FeedLoader
    
    var onRefresh: (([FeedItem]) -> Void)?
    
    init(feedLodaer: FeedLoader) {
        self.feedLoader = feedLodaer
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load(completion: { [weak self] result in
            if let items = try? result.get() {
                self?.onRefresh?(items)
            }
            self?.view.endRefreshing()
        })
    }
}
