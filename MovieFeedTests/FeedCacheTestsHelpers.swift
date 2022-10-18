//
//  FeedCacheTestsHelpers.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 18.10.22.
//

import Foundation
import MovieFeed

func uniqueFeedItem() -> FeedItem {
    return FeedItem(id: Int.random(in: 0...100), description: "any", title: "any", imageURL: "any")
}

func uniequeItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
    let models = [uniqueFeedItem(), uniqueFeedItem()]
    let local = models.map({LocalFeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.imageURL)})
    return (models, local)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
