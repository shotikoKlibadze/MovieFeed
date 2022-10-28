//
//  UIImageView+SetAnimation.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 27.10.22.
//

import UIKit

public extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        if newImage != nil {
            alpha = 0
            UIView.animate(withDuration: 0.25) {
                self.alpha = 0
            }
        }
    }
}
