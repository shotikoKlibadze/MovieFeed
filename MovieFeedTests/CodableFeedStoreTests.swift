//
//  CodableFeedStoreTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 19.10.22.
//

import XCTest
import MovieFeed

class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feedItems: [CodableFeedItem]
        let timeStamp: Date
        
        var localFeed: [LocalFeedItem] {
            return feedItems.map({$0.local})
        }
    }
    
    private struct CodableFeedItem: Codable {
        public let id: Int
        public let description: String?
        public let title: String?
        public let imageURL: String
        
        init(_ item: LocalFeedItem) {
            self.id = item.id
            self.description = item.description
            self.title = item.title
            self.imageURL = item.imageURL
        }
    
        var local: LocalFeedItem {
            return LocalFeedItem(id: id, description: description, title: title, imageURL: imageURL)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(items: cache.localFeed, timeStamp: cache.timeStamp))
        } catch {
            completion(.failure(error: error))
        }
    }
    
    func insertItems(items: [LocalFeedItem], date: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feedItems: items.map({CodableFeedItem($0)}), timeStamp: date)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteCachedFeed(completion: @escaping DelitionCompletion) {
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    
}

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
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timeStamp = Date()
        
        insert((items,timeStamp), to: sut)
         
        expect(sut, toRetrieve: .found(items: items, timeStamp: timeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrivalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalidData".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(error: anyNSError()))
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
        
        expect(sut, toRetrieve: .found(items: latestItems, timeStamp: latesttimeStamp))
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timeStamp = Date()
        
        insert((items, timeStamp), to: sut)
        let delitionError = delete(from: sut)
        XCTAssertNil(delitionError, "Expected to telete cache succesfully")
        
        expect(sut, toRetrieve: .empty)
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
            case (.empty, .empty), (.failure(error:_), .failure(error: _)):
                break
            case (.found(let retrievedItems,let retrievedTimeStamp),
                  .found(let expectedItems, let expectedTimeStamp)):
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
