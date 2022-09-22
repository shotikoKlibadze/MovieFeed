//
//  URLsesionHTTPClientTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 22.09.22.
//

import XCTest

class URLSessionHTTPClient {
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
    
}

class URLSessionHTTPClientTests : XCTestCase {
    
    
    func test_getFromURLcreatesSessionWithTheGivenURL() {
        let url = URL(string: "fakeURL")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.recievedURLs, [url])
    }
    
    
    //MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        
        var recievedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            recievedURLs.append(url)
            return URLSessionDatTaskSpy()
        }
        
    }
    
    private class URLSessionDatTaskSpy: URLSessionDataTask {
        
    }
    
    
}
