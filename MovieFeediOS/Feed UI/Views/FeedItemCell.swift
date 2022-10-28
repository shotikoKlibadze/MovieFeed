//
//  FeedItemCell.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

public class FeedItemCell: UITableViewCell {
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var imageContainer: UIView!
    @IBOutlet public var posterImageView: UIImageView!
    
    var isShimmering: Bool! {
        didSet {
            if isShimmering {
                imageContainer.startShimmering()
            } else {
                imageContainer.stopShimmering()
            }
        }
    }

    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }

}
