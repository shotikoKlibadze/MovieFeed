//
//  CacheFeedUseCaseTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 13.10.22.
//

import XCTest
import MovieFeed

class LocalFeedLoader {
    
    let store: FeedStore
    let currentDate: () -> Date
    
    init (store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            
            if error == nil {
                self.store.insertItems(items: items, date: currentDate())
            }
        }
    }
    
    
}

class FeedStore {
    
    typealias DelitionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
//    var deleteCachedFeedCallCount = 0
//    var insertCallCount = 0
    
    private var deletionCompletions = [DelitionCompletion]()
    private var insertionCompetions = [InsertionCompletion]()
    
    enum RecievedMessages: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var recievedMessages = [RecievedMessages]()
    
    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
//        deleteCachedFeedCallCount += 1
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
    
    func insertItems(items: [FeedItem], date: Date) {
        recievedMessages.append(.insert(items, date))
        //insertCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCachedUponeCreaction() {
        let (_ , store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestsCacheDelition() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesnotRequestCacheInsertionOnDelitionError() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNSError()
        
        sut.save(items: items)
        store.completeDelition(with: error)
       
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccesfullDeletion() {
        let timeStamp = Date()
        let (sut , store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items, timeStamp)])
    }
    
    // MARK: - Helpers -
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut:LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        checkForMemoryLeask(isntance: store, file: file, line: line)
        checkForMemoryLeask(isntance: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: Int.random(in: 0...100), description: "any", title: "any", imageURL: "any")
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }

}
