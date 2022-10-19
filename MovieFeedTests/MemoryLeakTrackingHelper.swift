//
//  MemoryLeakTrackingHelper.swift
//  MovieFeedTests
//
//  Created by Shotiko Klibadze on 03.10.22.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeacks(isntance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak isntance] in
            XCTAssertNil(isntance, "Instance should have been dealocated, Potential memory leak",file: file,line: line)
        }
    }
}
