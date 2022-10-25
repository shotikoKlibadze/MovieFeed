//
//  FeedViewController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var refreshController: RefreshViewController?
    
    var tableModels = [FeedItemCellController]() {
        didSet { tableView.reloadData() }
    }
   
    convenience init(refreshController: RefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        refreshController?.refresh()
        tableView.prefetchDataSource = self
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(at: indexPath).view()
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
