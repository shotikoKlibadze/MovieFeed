//
//  RefreshViewController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit

//MARK: - MVP Pattern -
final class RefreshViewController: NSObject, FeedLoadingView {
    
    lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }

}

//MARK: - MVVM Pattern -
//final class RefreshViewController: NSObject {
//
//    lazy var view = binded(UIRefreshControl())
//
//    private let viewModel: FeedViewModel
//
//    init(viewModel: FeedViewModel) {
//        self.viewModel = viewModel
//    }
//
//    @objc func refresh() {
//        viewModel.loadFeed()
//    }

//    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
//        viewModel.onLoadingStateChange = { [weak view] isLoading in
//            if isLoading {
//                view?.beginRefreshing()
//            } else {
//                view?.endRefreshing()
//            }
//        }
//        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        return view
//    }
//}
