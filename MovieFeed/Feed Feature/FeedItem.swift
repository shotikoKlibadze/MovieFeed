//
//  FeedItem.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import Foundation

public struct FeedItem: Equatable {
    
   public let id: Int
   public let description: String?
   public let title: String?
   public let imageURL: String
    
    public init(id: Int, description: String?, title: String?, imageURL: String) {
        self.id = id
        self.description = description
        self.title = title
        self.imageURL = imageURL
    }
}
