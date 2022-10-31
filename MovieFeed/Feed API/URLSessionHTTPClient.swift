//
//  URLSessionHTTPClient.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 03.10.22.
//

import Foundation

struct URLSessionTaskWrapper: HTTPClientTask {
    
    let wrapped: URLSessionTask
    
    func cancel() {
        wrapped.cancel()
    }
}

public class URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    

    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        task.resume()
        
        return URLSessionTaskWrapper(wrapped: task)
    }
    
}
