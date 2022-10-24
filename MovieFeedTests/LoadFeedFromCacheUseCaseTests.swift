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
        let items = uniqueItems()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut: sut, toCompleteWith: .success(items.models)) {
            store.completeRetrievalWith(items: items.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliversNoFeedItemsOnSevenDaysOldCache() {
        let items = uniqueItems()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrievalWith(items: items.local, timeStamp: sevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliversNoFeedItemsOnMoreThanSevenDaysOldCache() {
        let items = uniqueItems()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrievalWith(items: items.local, timeStamp: moreThanSevenDaysOldTimeStamp)
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load(completion: { _ in})
        store.completeRetrievalWith(error: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    func test_load_hasNoSideAffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load(completion: { _ in})
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    func test_load_hasNoSideEffectsOnLessThanSevenDaysOLD() {
        let items = uniqueItems()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load(completion: {_ in })
        store.completeRetrievalWith(items: items.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    func test_load_hasNosideEffectsOnSevenDaysOldCache() {
        let items = uniqueItems()
        let fixedCurrentDate = Date()
        let sevenDaysOldCache = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load(completion: {_ in })
        store.completeRetrievalWith(items: items.local, timeStamp: sevenDaysOldCache)
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    func test_load_haseNoSideEffectsOnMoreThanSevenDaysOldCache() {
        let items = uniqueItems()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldCache = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load(completion: {_ in })
        store.completeRetrievalWith(items: items.local, timeStamp: moreThanSevenDaysOldCache)
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    func test_load_doesNotDeliverResultAfterTheSUTinstanceHasBeenDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var recievedResults = [LocalFeedLoader.Result]()
        
        sut?.load(completion: {recievedResults.append($0)})
        
        sut = nil
        store.completeRetrievalWithEmptyCache()
        XCTAssertTrue(recievedResults.isEmpty)
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
        trackForMemoryLeacks(isntance: store, file: file, line: line)
        trackForMemoryLeacks(isntance: sut, file: file, line: line)
        return (sut, store)
    }

}
