//
//  FeedItemCellController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

final class FeedItemCellController {
    
    private var task: FeedItemImageDataLoaderTask?
    private var feedItem: FeedItem
    private var imageLoader: FeedItemImageDataLoader
    
    init(feedItem: FeedItem, imageLoader: FeedItemImageDataLoader) {
        self.feedItem = feedItem
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedItemCell()
        cell.configure(with: feedItem)
        cell.imageContainer.startShimmering()
        cell.imageRetryButton.isHidden = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self, let url = URL(string: self.feedItem.imageURL) else { return }
            self.task = self.imageLoader.loadImageData(from: url, completion: { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.posterImageView.image = image
                cell?.imageRetryButton.isHidden = (image != nil)
                cell?.imageContainer.stopShimmering()
            })
        }
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    func preload() {
        guard let url = URL(string: self.feedItem.imageURL) else { return }
        task = imageLoader.loadImageData(from: url, completion: { _ in } )
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
