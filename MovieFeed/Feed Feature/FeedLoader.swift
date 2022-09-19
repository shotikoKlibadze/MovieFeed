//
//  FeedLoader.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping (Result<[FeedItem],Error>) -> Void)
}
