//
//  FeedCachePolicy.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 19.10.22.
//

import Foundation

final class FeedCachePolicy {
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays : Int {
        return 7
    }
    
    private init() {}
    
    static func validate(_ timeStamp: Date, against date: Date) -> Bool {
        guard let maxAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else { return false }
        return date < maxAge
    }
    
}
