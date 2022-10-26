//
//  FeedItemCell.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

public class FeedItemCell: UITableViewCell {
    public let titleLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let posterImageView = UIImageView()
   
    
    public lazy var imageRetryButton: UIButton = {
        let imageRetryButton = UIButton()
        imageRetryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return imageRetryButton
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    func configure(with item: FeedItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }
}
