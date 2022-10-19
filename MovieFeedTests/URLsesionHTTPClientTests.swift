//
//  URLsesionHTTPClientTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 22.09.22.
//

import XCTest
import MovieFeed

class URLSessionHTTPClientTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGetRequestWithURL() {
    
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
        
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let recievedError = resultErrorFor(data: nil, response: nil, error: requestError)
        XCTAssertEqual(recievedError as NSError?, requestError)
    }
    
    func test_getFromURL_suceedsOnHTTPURLresponsWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(recievedData, recievedResponse):
                XCTAssertEqual(data, recievedData)
                //XCTAssertEqual(response, recievedResponse)
                XCTAssertEqual(response.statusCode, recievedResponse.statusCode)
                XCTAssertEqual(response.url, recievedResponse.url)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
//    func test_getFromURL_failsOnAllInvalidPrepresentationCases()

    //MARK: - Helpers-
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeacks(isntance: sut,file: file, line: line)
        return URLSessionHTTPClient()
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file:file,line: line)
        
        let exp = expectation(description: "Wait for completion")
        var recievedError: Error?
        sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error as NSError?):
                if let error = error {
                    //Filtered it because the error was comming with options from URLPRotocolClass
                    let filteredError = NSError(domain: error.domain, code: error.code)
                    recievedError = filteredError
                }
            default:
                XCTFail("Failure", file: file , line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recievedError
    }
    
   
    private func anyData() -> Data {
        return Data.init()
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
            
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
