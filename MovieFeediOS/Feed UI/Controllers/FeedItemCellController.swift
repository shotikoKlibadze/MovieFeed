//
//  FeedItemCellController.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestFeedItem()
    func didCancelImageRequest()
}

final class FeedItemCellController: FeedItemView {

    typealias Image = UIImage
    
    private var cell: FeedItemCell?
    
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemCell") as! FeedItemCell
        self.cell = cell
        delegate.didRequestFeedItem()
        return cell
    }
    
    func preload() {
        delegate.didRequestFeedItem()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(_ model: FeedItemViewModel) {
        cell?.descriptionLabel.text = model.description
        cell?.titleLabel.text = model.title
        cell?.posterImageView.setImageAnimated(model.image)
        cell?.isShimmering = model.isLoading
        cell?.onRetry = delegate.didRequestFeedItem
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}



//MARK: -MVVM Pattern-

//final class FeedItemCellController {
//
//    let viewModel: FeedItemViewModel
//
//    init(viewModel: FeedItemViewModel) {
//        self.viewModel = viewModel
//    }
//
//    func view() -> UITableViewCell {
//        let cell = binded(cell: FeedItemCell())
//        viewModel.loadImage()
//        return cell
//    }
//
//    func binded(cell: FeedItemCell) -> FeedItemCell {
//        cell.descriptionLabel.text = viewModel.descriptiom
//        cell.titleLabel.text = viewModel.tittle
//        viewModel.onIsLoaded = { [weak cell] isLoaded in
//            if isLoaded {
//                cell?.stopShimmering()
//            } else { cell?.startShimmering() }
//        }
//        viewModel.onImageLoad = { [weak cell] image in
//            cell?.posterImageView.image = image
//        }
//
//        viewModel.shouldRetryToReload = { [weak cell] shouldRetry in
//            cell?.imageRetryButton.isHidden = !shouldRetry
//        }
//        cell.onRetry = viewModel.reloadImage
//        return cell
//    }
//
//    func preload() {
//        viewModel.loadImage()
//    }
//
//    func cancelLoad() {
//        viewModel.cancelLoad()
//    }
//}
