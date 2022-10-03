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
    
    func test_getFromURL_performsGetRequestWithURL() {
        URLProtocolStub.startInterceptingRequests()
        
        let url = URL(string: "fakeURL")!
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
        
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "fakeURL")!
        let error = NSError(domain: "any error", code: 1)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for completion")
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
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
        wait(for: [exp], timeout: 3.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    
    
    //MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
         
        private static var stub: Stub?
        
        static var requestObserver: ((URLRequest) -> ())?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(obsever: @escaping (URLRequest) -> Void) {
            requestObserver = obsever
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        //By this you can intersept the request and do whatever you want to do with it.
        override class func canInit(with request: URLRequest) -> Bool {
            //Intersept all the requests to check if the problem is coming from bad URL or request error
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        //This will be invoked when your canInnit returns TRUE.
        override func startLoading() {
        
            //Need to tell the urlLoadingSystem what happend when we intercepted the URLsession.
            //CLIENT is object that is used to communicate with url loading system
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        // You need to implement this even though you dont have logic for it
        override func stopLoading() {}
        
    }
}
