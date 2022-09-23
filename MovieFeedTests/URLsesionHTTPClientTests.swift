//
//  URLsesionHTTPClientTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 22.09.22.
//

import XCTest
import MovieFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler:
                  @escaping (Data?, URLResponse?, Error?)
                  -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

class URLSessionHTTPClient {
    
    let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
}

class URLSessionHTTPClientTests : XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "fakeURL")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, task: task)
        
        
        sut.get(from: url){ _ in }
        
        XCTAssertEqual(task.resumedTasksCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "fakeURL")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "any error", code: 1)

        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, error: error)
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case .failure(let recievedError as NSError):
                XCTAssertEqual(error, recievedError)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    //MARK: - Helpers
    
    private class HTTPSessionSpy: HTTPSession {
         
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
            let task: HTTPSessionDataTask
        }
        
        func stub(url: URL,
                  task: HTTPSessionDataTask =
                  URLSessionDataTaskSpy(),
                  error: Error? = nil) {
            stubs[url] = Stub(error: error, task: task)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
            
            if let stub = stubs[url] {
                completionHandler(nil, nil, stub.error)
                return stub.task
            }
            
            return URLSessionDataTaskSpy()
        }
        
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionDataTask {
        var resumedTasksCount = 0
        
        func resume() {
            resumedTasksCount += 1
        }
    }

}
