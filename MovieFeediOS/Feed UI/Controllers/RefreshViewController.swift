//
//  RefreshViewController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit

final class RefreshViewController: NSObject {
    
    lazy var view = binded(UIRefreshControl())
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
