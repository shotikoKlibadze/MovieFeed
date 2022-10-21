//
//  CoreDataFeedStoreTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 21.10.22.
//

import XCTest
import MovieFeed

final class CoreDataFeedStoreTests: XCTestCase {
    
    
    func test_init_doesntThrowErrorUponCreation() {
        var recievedError: Error?
        do {
            let storeBundle = Bundle(for: CoreDataFeedStore.self)
            let storeURL = URL(fileURLWithPath: "/dev/null")
            _ = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        } catch {
            recievedError = error
        }
        
        XCTAssertNil(recievedError)
    }
    
    func test_insert_retrieve_retrievesInsertedDataWithCorrectTimeStamp() {
        let sut = makeSUT()
        let testItems = uniqueItems().local
        let testTimpeStamp = Date()
        
        var recievedInsertionError: Error?
        var recievedRetrievalError: Error?
        
        let insertExp = expectation(description: "wait for insertion")
        
        sut.insertItems(items: testItems, date: testTimpeStamp) { error in
            recievedInsertionError = error
            insertExp.fulfill()
        }
        
        var recievedItems = [LocalFeedItem]()
        var recievedTimeStamp: Date?
        let retrieveExp = expectation(description: "wait for retrieval")
        sut.retrieve { result in
            switch result {
            case .failure(error: let error):
                recievedRetrievalError = error
            case .found(items: let items, timeStamp: let timeStamp):
                recievedItems = items
                recievedTimeStamp = timeStamp
            case .empty:
                break
            }
            retrieveExp.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertNil(recievedRetrievalError)
        XCTAssertNil(recievedInsertionError)
        XCTAssertEqual(testItems, recievedItems)
        XCTAssertEqual(testTimpeStamp, recievedTimeStamp)
    }
    
    func test_delete_dosntRetrieveAnyDataAfterDeletion() {
        let sut = makeSUT()
        let testItems = uniqueItems().local
        let testTimpeStamp = Date()
        
        var recievedInsertionError: Error?
        var recievedRetrievalError: Error?
        var recievedDeletionError: Error?
        
        let insertExp = expectation(description: "wait for insertion")
        
        sut.insertItems(items: testItems, date: testTimpeStamp) { error in
            recievedInsertionError = error
            insertExp.fulfill()
        }
        
        let deletionExp = expectation(description: "wait for delition")
        
        sut.deleteCachedFeed { error in
            recievedDeletionError = error
            deletionExp.fulfill()
        }
        
        var recievedItems = [LocalFeedItem]()
        var recievedTimeStamp: Date?
        let retrieveExp = expectation(description: "wait for retrieval")
        sut.retrieve { result in
            switch result {
            case .failure(error: let error):
                recievedRetrievalError = error
            case .found(items: let items, timeStamp: let timeStamp):
                recievedItems = items
                recievedTimeStamp = timeStamp
            case .empty:
                break
            }
            retrieveExp.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertNil(recievedRetrievalError)
        XCTAssertNil(recievedInsertionError)
        XCTAssertNil(recievedDeletionError)
        XCTAssertNil(recievedTimeStamp)
        XCTAssertEqual([], recievedItems)
    }



    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeacks(isntance: sut, file: file, line: line)
        return sut
    }
    
}
