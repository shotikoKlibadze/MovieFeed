//
//  RemoteFeedLoaderTests.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 17.07.22.
//

import XCTest
import MovieFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    //Make request call once
    func test_load_requestsDatFromURL() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        
    }
    
   //Make netwrok call twice
    func test_loadTwice_requestsDatFromURLTwice() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{ _ in }
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    //Delivers one error
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity)) {
            let error = NSError(domain: "Test", code: 0)
            client.complete(with: error)
        }
    }
    
    //Delivers error on HTTPResponse (invalid data)
    //CHecking how many times the completion is completed is important.
    func test_load_deliversErrorOnNo200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        [199, 201, 300, 400, 500].enumerated().forEach { index, code  in
            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemsJson(items: [])
                client.complete(withstatusCode: code, data: json, at: index)
            }
        }
    }
       
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data.init()
            client.complete(withstatusCode: 200, data: invalidJSON)
        }
    }
    
//    func test_load_DeliversNoItemsOn200HTTPResponseWihtEmptyJSONList() {
//        let (sut, client) = makeSUT()
//        
//        expect(sut, toCompleteWith: .success([])) {
//            let emptyListJson = makeItemsJson(items: [])
//            client.complete(withstatusCode: 200, data: emptyListJson)
//        }
//        
//    }
    
//    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
//        let (sut, client) = makeSUT()
//        let item1 = makeItem(id: UUID(), imageURL: URL(string: "http://a-url.com")!)
//        let item2 = makeItem(id: UUID(), description: "des", location: "loc", imageURL: URL(string: "http://another-url.com")!)
//
//        let items = [item1.model, item2.model]
//
//        expect(sut, toCompleteWith: .success(items)) {
//            let json =  makeItemsJson(items: [item1.json,item2.json])
//            client.complete(withstatusCode: 200, data: json)
//        }
//    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDealocated() {
        let url = URL(string: "someurlr")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client:client, url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut?.load { capturedResults.append($0)}
        
        sut = nil
        client.complete(withstatusCode: 200, data: makeItemsJson(items: []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    //MARK: - Helpers -
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, clinet: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        checkForMemoryLeask(isntance: client)
        checkForMemoryLeask(isntance: sut)
        return (sut, client)
    }
    
//    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model:FeedItem, json: [String: Any]) {
//        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
//
//        let itemJSON = [
//            "id": item.id.uuidString,
//            "description" : item.description,
//            "location": item.title,
//            "image": item.imageURL.absoluteString
//        ].compactMapValues{$0}
//        return (item, itemJSON)
//    }
    
    private func makeItemsJson(items: [[String: Any]]) -> Data {
        let JSONdata =  try! JSONSerialization.data(withJSONObject: ["items": items])
        return JSONdata
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load to complete")
        
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedItems), .success(expectedItems)):
                XCTAssertEqual(recievedItems, expectedItems, file: file, line: line)
            case let (.failure(recievedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        action()
        waitForExpectations(timeout: 1)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion:(HTTPClientResult) -> Void )]()
        
        var requestedURLs : [URL] {
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping  (HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withstatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
            
        }
    }

}
