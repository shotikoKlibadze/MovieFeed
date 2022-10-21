//
//  MovieFeedCacheIntegrationTests.swift
//  MovieFeedCacheIntegrationTests
//
//  Created by Shotiko Klibadze on 21.10.22.
//

import XCTest
import MovieFeed
import MovieFeedTests

final class MovieFeedCacheIntegrationTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        deletStoreArtifacts()
    }
    
    override func setUp() {
        super.setUp()
        deletStoreArtifacts()
    }
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        let sut = makeFeedLoader()
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, [])
            case .failure(_):
                XCTFail()
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversitemsSavedOnAseperateInsance() {
        let savingSUT = makeFeedLoader()
        let retrieveingSUT = makeFeedLoader()
        
        let items = uniqueItems().models
        let savExp = expectation(description: "wait for saving")
        savingSUT.save(items: items) { error in
            XCTAssertNil(error)
            savExp.fulfill()
        }
        wait(for: [savExp], timeout: 1.0)
        
        let retrieveExp = expectation(description: "wait for retrieving")
        retrieveingSUT.load { result in
            switch result {
                
            case .success(let recievedItems):
                XCTAssertEqual(recievedItems, items)
            case .failure(_):
                XCTFail("Not THe Same")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }
    
    func test_save_overridesItemsSavedOnASeperateInstance() {
        
    }
    

    // MARK: - Helpers
    
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        print(storeURL)
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeacks(isntance: sut)
        return sut
    }
        
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deletStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
