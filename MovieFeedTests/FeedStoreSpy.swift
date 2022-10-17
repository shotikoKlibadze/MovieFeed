//
//  FeedStoreSpy.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 17.10.22.
//

import Foundation
import MovieFeed

class FeedStoreSpy: FeedStore {
    
    typealias DelitionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Result<[FeedItem], Error>) -> Void
    
    private var deletionCompletions = [DelitionCompletion]()
    private var insertionCompetions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    enum RecievedMessages: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedItem], Date)
        case retrieveItems
    }
    
    private(set) var recievedMessages = [RecievedMessages]()
    
    //MARK: -Saving-
    
    func deleteCachedFeed(completion: @escaping DelitionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCachedFeed)
    }
    
    func completeDelition(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompetions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompetions[index](nil)
    }
    
    func insertItems(items: [LocalFeedItem], date: Date, completion: @escaping InsertionCompletion) {
        recievedMessages.append(.insert(items, date))
        insertionCompetions.append(completion)
    }
    
    //MARK: Retrival
    
    func retrieveItems(completion: @escaping (Result<[MovieFeed.FeedItem], Error>) -> Void) {
        retrievalCompletions.append(completion)
        recievedMessages.append(.retrieveItems)
    }
    
    
    func completeRetrievalWith(error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache() {
        retrievalCompletions[0](.success([]))
    }
}
