//
//  FeedViewController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

protocol FeedItemImageDataLoader {
    func loadImageData(from url: URL)
}

final public class FeedViewController: UITableViewController {
    
    private var feedLoader: FeedLoader?
    private var feedItems = [FeedItem]()
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.feedLoader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
       load()
    }
    
    @objc private func load() {
        feedLoader?.load(completion: { [weak self] result in
            if let items = try? result.get() {
                self?.feedItems = items
                self?.tableView.reloadData()
            }
//            switch result {
//            case .success(let items):
//                self?.feedItems = items
//                self?.tableView.reloadData()
//            case .failure(_):
//                break
//            }
            self?.refreshControl?.endRefreshing()
        })
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feedItems.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = feedItems[indexPath.row]
        let cell = FeedItemCell()
        cell.configure(with: cellModel)
        return cell
    }
}
