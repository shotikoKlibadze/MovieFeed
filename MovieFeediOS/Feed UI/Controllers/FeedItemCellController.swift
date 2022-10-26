//
//  FeedItemCellController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit

final class FeedItemCellController {
    
    let viewModel: FeedItemViewModel
    
    init(viewModel: FeedItemViewModel) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(cell: FeedItemCell())
        viewModel.loadImage()
        return cell
    }
    
    func binded(cell: FeedItemCell) -> FeedItemCell {
        cell.descriptionLabel.text = viewModel.descriptiom
        cell.titleLabel.text = viewModel.tittle
        viewModel.onIsLoaded = { [weak cell] isLoaded in
            if isLoaded {
                cell?.stopShimmering()
            } else { cell?.startShimmering() }
        }
        viewModel.onImageLoad = { [weak cell] image in
            cell?.posterImageView.image = image
        }
        
        viewModel.shouldRetryToReload = { [weak cell] shouldRetry in
            cell?.imageRetryButton.isHidden = !shouldRetry
        }
        cell.onRetry = viewModel.reloadImage
        return cell
    }
    
    func preload() {
        viewModel.loadImage()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
    }
}
