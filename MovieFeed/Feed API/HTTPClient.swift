//
//  HTTPClient.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.09.22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropraite thread 
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
