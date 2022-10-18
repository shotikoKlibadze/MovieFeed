//
//  LoadFeedFromCacheUseCaseTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 17.10.22.
//

import XCTest
import MovieFeed


class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesntMessageStoreUponCreation() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.store.recievedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let loadError = anyNSError()
        
        expect(sut: sut, toCompleteWith: .failure(loadError)) {
            store.completeRetrievalWith(error: loadError)
        }
    }
    
    func test_load_deliversEmptyFeedOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedFeedItemsOnLessThanSevenDaysOldCache() {
        let items = uniequeItems()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut: sut, toCompleteWith: .success(items.models)) {
            store.completeRetrievalWith(items: items.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliversNoFeedItemsOnSevenDaysOldCache() {
        let items = uniequeItems()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrievalWith(items: items.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        }
    }
    
    //MARK: -Helpers-
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: (Result<[FeedItem], Error>), when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case (.success(let recievedItems), .success(let expectedItems)):
                XCTAssertEqual(recievedItems, expectedItems)
            case (.failure(let recievedError as NSError), .failure(let expecterError as NSError)):
                XCTAssertEqual(recievedError, expecterError)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut:LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        checkForMemoryLeask(isntance: store, file: file, line: line)
        checkForMemoryLeask(isntance: sut, file: file, line: line)
        return (sut, store)
    }

    func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: Int.random(in: 0...100), description: "any", title: "any", imageURL: "any")
    }
    
    private func uniequeItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
        let models = [uniqueFeedItem(), uniqueFeedItem()]
        let local = models.map({LocalFeedItem(id: $0.id, description: $0.description, title: $0.title, imageURL: $0.imageURL)})
        return (models, local)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
