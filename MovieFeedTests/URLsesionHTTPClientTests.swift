//
//  URLsesionHTTPClientTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 22.09.22.
//

import XCTest
import MovieFeed

class URLSessionHTTPClient {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
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
        
    func test_getFromURL_failsOnRequestError() {
        URLProtocol.registerClass(URLProtocolStub.self)
        let url = URL(string: "fakeURL")!
        let error = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(url: url, error: error)

        let sut = URLSessionHTTPClient()
      
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case .failure(let recievedError as NSError):
                //Filtered it because the error was comming with options for URLPRotocolClass
                let filteredError = NSError(domain: recievedError.domain, code: recievedError.code)
                XCTAssertEqual(error, filteredError)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    
    
    //MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
         
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        //By this you can intersept the request and do whatever you want to do with it.
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        //This will be invoked when your canInnit returns TRUE.
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                //Need to tell the urlLoadingSystem that we failed.
                //Client is object that used to communicate for url loading system
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        // You need to implement this even though you dont have logic for it
        override func stopLoading() {}
        
    }
}
