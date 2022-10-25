//
//  FeedViewController.swift
//  Prototype
//
//  Created by Shotiko Klibadze on 24.10.22.
//

import UIKit

class FeedViewController: UITableViewController {
    
    private var feedItems = [FeedItemViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.feedItems.isEmpty {
                self.feedItems = FeedItemViewModel.mockData()
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feedItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let model = feedItems[indexPath.row]
        cell.configure(with: model)
        return cell
    }

}
