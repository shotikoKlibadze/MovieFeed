//
//  FeedItemPresenter.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 27.10.22.
//

import MovieFeed
import UIKit

protocol FeedItemView {
    func display(_ model: FeedItemViewModel)
}

final class FeedItemPresenter {
    
    let view: FeedItemView
    
    init(view: FeedItemView) {
        self.view = view
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didStartLoadingImageData(for model: FeedItem) {
        view.display(FeedItemViewModel(title: model.title, description: model.description, image: nil, isLoading: true, shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data?, for model: FeedItem) {
        let image = data.map(UIImage.init) ?? nil
        view.display(FeedItemViewModel(title: model.title, description: model.description, image: image, isLoading: false, shouldRetry: image == nil))
    }
}

