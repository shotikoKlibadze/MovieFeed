//
//  HTTPClient.swift
//  MovieFeed
//
//  Created by Shotiko Klibadze on 21.09.22.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse),Error>
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropraite thread 
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void)
}
