//
//  FeedCell.swift
//  Prototype
//
//  Created by Shotiko Klibadze on 24.10.22.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        posterImageView.alpha = 0
        posterImageView.image = nil
    }
    
    func fadeIn(_ image: UIImage?) {
        posterImageView.image = image
        
        UIView.animate(withDuration: 1, delay: 0.3) {
            self.posterImageView.alpha = 1
        }
    }

    
    func configure(with model: CellViewModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        fadeIn(UIImage(named: model.image))
    }

}
