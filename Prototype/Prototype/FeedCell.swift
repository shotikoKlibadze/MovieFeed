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
    @IBOutlet weak var imageContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.alpha = 0
        imageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        posterImageView.alpha = 0
        posterImageView.image = nil
        imageContainer.startShimmering()
    }
    
    func fadeIn(_ image: UIImage?) {
        posterImageView.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.25,
            options: [],
            animations: {
                self.posterImageView.alpha = 1
            }, completion: { completed in
                if completed {
                    self.imageContainer.stopShimmering()
                }
            })
    }

    
    func configure(with model: FeedItemViewModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        fadeIn(UIImage(named: model.image))
    }

}

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }
    
    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }
    
    func stopShimmering() {
        layer.mask = .none
    }
}
