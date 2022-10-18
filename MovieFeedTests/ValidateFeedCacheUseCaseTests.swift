//
//  ValidateFeedCacheUseCaseTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 18.10.22.
//

import XCTest
import MovieFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    
    func test_init_doesntMessageStoreUponCreation() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.store.recievedMessages, [])
    }
    
    func test_validateCache_deletesCachedFeedOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWith(error: anyNSError())
         
        XCTAssertEqual(store.recievedMessages, [.retrieveItems, .deleteCachedFeed])
    }
    
    func test_validateCache_DoesNotDeleteOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    func test_load_doesnotdeletesCachedOnLessThanSevenDaysOLD() {
        let items = uniequeItems()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrievalWith(items: items.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieveItems])
    }
    
    
    
    //MARK: -Helpers-
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut:LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        checkForMemoryLeask(isntance: store, file: file, line: line)
        checkForMemoryLeask(isntance: sut, file: file, line: line)
        return (sut, store)
    }
    
}

