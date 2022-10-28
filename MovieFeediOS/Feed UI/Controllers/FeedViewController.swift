//
//  FeedViewController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

protocol FeedLoadingView {
    func display(model: FeedLoadingViewModel)
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView {
    
    var delegate: FeedViewControllerDelegate?
    
    var tableModels = [FeedItemCellController]() {
        didSet { tableView.reloadData() }
    }
   
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        tableView.prefetchDataSource = self
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(model: FeedLoadingViewModel) {
        if model.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(at: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(at: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(at: indexPath).cancelLoad()
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedItemCellController {
        let controller = tableModels[indexPath.row]
        return controller
    }
}
