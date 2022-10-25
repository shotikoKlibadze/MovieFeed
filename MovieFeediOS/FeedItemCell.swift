//
//  FeedItemCell.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 25.10.22.
//

import UIKit
import MovieFeed

class FeedItemCell: UITableViewCell {
    public let titleLabel = UILabel()
    public let descriptionLabel = UILabel()
    
    func configure(with item: FeedItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }
}
