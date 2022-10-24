//
//  CodableFeedStoreTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 19.10.22.
//

import XCTest
import MovieFeed

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // We do this here also because some times during debuging or something else the tearDown() method is not called.
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        //If dont do this after running test there will be some data inside the file manager and some tests will fail.
        setupEmptyStoreState()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .success(.empty))
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timeStamp = Date()
        
        insert((items,timeStamp), to: sut)
         
        expect(sut, toRetrieve: .success(.found(items: items, timeStamp: timeStamp)))
    }
    
    func test_retrieve_deliversFailureOnRetrivalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalidData".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_insert_ovverridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        let firstInsertionItems = uniqueItems().local
        let firstTimeStamp = Date()
        
        let firstInsertinError = insert((firstInsertionItems, firstTimeStamp), to: sut)
        XCTAssertNil(firstInsertinError, "expected to insert cache succesfully")
        
        let latestItems = uniqueItems().local
        let latesttimeStamp = Date()
        let latestInsertionError = insert((latestItems,latesttimeStamp), to: sut)
        XCTAssertNil(latestInsertionError, "expected to override cache succesfully")
        
        expect(sut, toRetrieve: .success(.found(items: latestItems, timeStamp: latesttimeStamp)))
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timeStamp = Date()
        
        insert((items, timeStamp), to: sut)
        let delitionError = delete(from: sut)
        XCTAssertNil(delitionError, "Expected to telete cache succesfully")
        
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_runsSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "operation 1")
        sut.insertItems(items: uniqueItems().local, date: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "operation 3")
        sut.insertItems(items: uniqueItems().local, date: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Finished in wrong order")
    }
    
    
    //MARK: -Helpers-
    
    func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let url = testSpecificStoreURL()
        let sut = CodableFeedStore(storeURL: storeURL ?? url)
        trackForMemoryLeacks(isntance: sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.success(.empty), .success(.empty)), (.failure(_), .failure(_)):
                break
            case (.success(.found(let retrievedItems,let retrievedTimeStamp)),
                  .success(.found(let expectedItems, let expectedTimeStamp))):
                XCTAssertEqual(retrievedItems, expectedItems, file: file, line:line)
                XCTAssertEqual(retrievedTimeStamp, expectedTimeStamp, file : file, line:line)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    @discardableResult
    private func insert(_ cache: (feed:[LocalFeedItem], timpeStampe: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache retrieval")
        var recievedError: Error?
        sut.insertItems(items: cache.feed, date: cache.timpeStampe) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted succesfully")
            recievedError = insertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return recievedError
    }
    
    @discardableResult
    private func delete(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        sut.deleteCachedFeed { error in
            deletionError = error
        }
        return deletionError
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        let storeURL = testSpecificStoreURL()
        try? FileManager.default.removeItem(at: storeURL)
    }

}
