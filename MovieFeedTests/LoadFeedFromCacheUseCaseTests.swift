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
}
