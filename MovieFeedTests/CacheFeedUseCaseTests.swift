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
    
    func save(items: [FeedItem], completion: @escaping (Error?) -> Void ) {
        store.deleteCachedFeed { [unowned self] error in
            
            if error == nil {
                self.store.insertItems(items: items, date: currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    
    typealias DelitionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DelitionCompletion)
    func insertItems(items: [FeedItem], date: Date, completion: @escaping InsertionCompletion)
}



final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCachedUponeCreaction() {
        let (_ , store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestsCacheDelition() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items) { _ in}
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesnotRequestCacheInsertionOnDelitionError() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNSError()
        
        sut.save(items: items) { _ in}
        store.completeDelition(with: error)
       
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccesfullDeletion() {
        let timeStamp = Date()
        let (sut , store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items) { _ in}
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items, timeStamp)])
    }
    
    func test_save_failsOnDelitionError() {
        let (sut , store) = makeSUT()
        let delitionError = anyNSError()
       
        expect(sut, toCompleteWithError: delitionError) {
            store.completeDelition(with: delitionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut , store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccesfullInsertion() {
        let (sut , store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    // MARK: - Helpers -
    
    private class FeedStoreSpy: FeedStore {
       
        typealias DelitionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void
        
        private var deletionCompletions = [DelitionCompletion]()
        private var insertionCompetions = [InsertionCompletion]()
        
        enum RecievedMessages: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }
        
        private(set) var recievedMessages = [RecievedMessages]()
        
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
        
        func insertItems(items: [FeedItem], date: Date, completion: @escaping InsertionCompletion) {
            recievedMessages.append(.insert(items, date))
            insertionCompetions.append(completion)
        }
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var recievedError: Error?
        let exp = expectation(description: "wait for error")
        sut.save(items: [uniqueItem()]) { error in
            recievedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(recievedError as? NSError, expectedError, file: file, line: line)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut:LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
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
