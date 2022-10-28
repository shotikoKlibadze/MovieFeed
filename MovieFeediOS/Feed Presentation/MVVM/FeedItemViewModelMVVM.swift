//
//  FeedItemViewModel.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 26.10.22.
//

import Foundation
import MovieFeed
import UIKit

//final class FeedItemViewModel {
//    
//    typealias Observer<T> = (T) -> Void
//    
//    private var task: FeedItemImageDataLoaderTask?
//    private var feedItem: FeedItem
//    private var imageLoader: FeedItemImageDataLoader
//    
//    var tittle: String? {
//        return feedItem.title
//    }
//    var descriptiom: String? {
//        return feedItem.description
//    }
//    
//    var reloadImage: (() -> Void)?
//    
//    var onImageLoad: Observer<UIImage?>?
//    var onIsLoaded: Observer<Bool>?
//    var shouldRetryToReload: Observer<Bool>?
//    
//    init(feedItem: FeedItem, imageLoader: FeedItemImageDataLoader) {
//        self.feedItem = feedItem
//        self.imageLoader = imageLoader
//    }
//    
//    func loadImage() {
//        onIsLoaded?(false)
//        shouldRetryToReload?(false)
//        reloadImage = { [weak self] in
//            guard let self = self, let url = URL(string: self.feedItem.imageURL) else { return }
//            self.task = self.imageLoader.loadImageData(from: url, completion: { [weak self] result in
//                let data = try? result.get()
//                let image = data.map(UIImage.init) ?? nil
//                self?.onImageLoad?(image)
//                self?.onIsLoaded?(true)
//                self?.shouldRetryToReload?(image == nil)
//            })
//        }
//        reloadImage?()
//    }
//    
//    func cancelLoad() {
//        task?.cancel()
//    }
//}



