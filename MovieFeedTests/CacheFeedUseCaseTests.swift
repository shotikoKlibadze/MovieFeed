//
//  CacheFeedUseCaseTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 13.10.22.
//

import XCTest
import MovieFeed

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
        let localItems = items.map({LocalFeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.imageURL)})
        sut.save(items: items) { _ in}
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(localItems, timeStamp)])
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
    
    func test_doesnotDeliverAnDeletionErrorIfSUTInstanceIsDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var completions = [LocalFeedLoader.SaveResult]()
        
        sut?.save(items: [uniqueItem()], completion: {completions.append($0)})
        sut = nil
        store.completeDelition(with: anyNSError())
        
        XCTAssertTrue(completions.isEmpty)
    }
    
    func test_doesnotDeliverAnInsertionErrorIfSUTInstanceIsDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var completions = [LocalFeedLoader.SaveResult]()
        
        sut?.save(items: [uniqueItem()], completion: {completions.append($0)})
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(completions.isEmpty)
    }
    
    // MARK: - Helpers -
    
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
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut:LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeacks(isntance: store, file: file, line: line)
        trackForMemoryLeacks(isntance: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: Int.random(in: 0...100), description: "any", title: "any", imageURL: "any")
    }
    
    private func uniqueFeedItem() -> (models: [FeedItem], local: [LocalFeedItem]) {
        let models = [uniqueItem(), uniqueItem()]
        let local = models.map({LocalFeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.imageURL)})
        return (models, local)
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }

}
