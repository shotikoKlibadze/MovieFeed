//
//  SharedTestHelpers.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 18.10.22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any Error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
