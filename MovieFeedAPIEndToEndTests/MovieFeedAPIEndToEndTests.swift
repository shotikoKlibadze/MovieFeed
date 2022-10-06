//
//  MovieFeedAPIEndToEndTests.swift
//  MovieFeedAPIEndToEndTests
//
//  Created by Shotiko Klibadze on 06.10.22.
//

import XCTest
import MovieFeed

let urlString = "https://api.themoviedb.org/3/tv/on_the_air?api_key=f4fc52063b2419f14cdaa0ac0fd23462&language=en-US&page=1"

class MovieFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestGetFeedResult_matchesExpectedData() {
        let url = URL(string: urlString)!
        let client = URLSessionHTTPClient()
        let feedLoader = RemoteFeedLoader(client: client, url: url)
        
        var recievedResult: LoadFeedResult?
        
        let exp = expectation(description: "wait for recieved data from server")
        
        feedLoader.load { result in
            recievedResult = result
            exp.fulfill()
         
        }
       
        wait(for: [exp], timeout: 5.0)
        
        switch recievedResult {
        case let .success(items):
            XCTAssertEqual(items.count, 20)
        case let .failure(error):
            XCTFail("recieved an error \(error)")
        default:
            XCTFail()
        }
    }
}
