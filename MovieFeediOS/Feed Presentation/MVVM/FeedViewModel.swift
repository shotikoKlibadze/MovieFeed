//
//  FeedViewModel.swift
//  MovieFeediOS
//
//  Created by Shotiko Klibadze on 26.10.22.
//

import Foundation
import MovieFeed

//final class FeedViewModel {
//    
//    typealias Observer<T> = (T) -> Void
//    
//    private let feedLoader: FeedLoader
//    
//    var onFeedLoad: Observer<[FeedItem]>?
//    var onLoadingStateChange: Observer<Bool>?
//    
//    init(feedLodaer: FeedLoader) {
//        self.feedLoader = feedLodaer
//    }
//    
//    func loadFeed() {
//        onLoadingStateChange?(true)
//        feedLoader.load(completion: { [weak self] result in
//            if let items = try? result.get() {
//                self?.onFeedLoad?(items)
//            }
//            self?.onLoadingStateChange?(false)
//        })
//    }
//}

