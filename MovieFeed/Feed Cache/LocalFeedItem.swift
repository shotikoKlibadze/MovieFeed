//
//  LocalFeedItem.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.10.22.
//

import Foundation

//DTO Data Tranfer Object to decuple storage framework from feed item data models
public struct LocalFeedItem: Equatable {
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

