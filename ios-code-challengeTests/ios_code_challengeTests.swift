//
//  ios_code_challengeTests.swift
//  
//
//  Created by Ryan Novak on 2019-10-11.
//

import XCTest

@testable import ios_code_challenge

class ios_code_challengeTests: XCTestCase {
    override func setUp() {
        // If our query only had one initializer to test (or we made a separate test class for tests with the other initializer), we could initialize our query here
        // No setup needed for these tests
    }

    override func tearDown() {
        // No teardown needed for this class
    }
    
    func getMessage(field: String, found: String, expected: String) -> String {
        return "YLPSearchQuery: Param \(field) doesn't match passed in \(field) (found: \(found), expected: \(expected))"
    }
    
    func testAddressSearchQueryParams() {
        let expectedAddress = "123 Fake St., Minneapolis, MN 55022"
        let query = YLPSearchQuery(location: expectedAddress)
        
        let parameters = query.parameters()
        
        XCTAssert(parameters["location"] as? String == expectedAddress,
                  getMessage(field: "location", found: "\(parameters["location"] ?? "Nil?")", expected: expectedAddress))
    }

    func testCoordinateSearchQueryParams() {
        let expectedLatitude = -75.52637
        let expectedLongitude = 53.84
        let query = YLPSearchQuery(latitude: NSNumber(value: expectedLatitude), andLongitude: NSNumber(value: expectedLongitude))
        
        let parameters = query.parameters()
        
        XCTAssert(parameters["latitude"] as? Double == expectedLatitude,
                  getMessage(field: "latitude", found: "\(parameters["latitude"] ?? "NIL?")", expected: "\(expectedLatitude)"))
        XCTAssert(parameters["longitude"] as? Double == expectedLongitude,
                  getMessage(field: "longitude", found: "\(parameters["longitude"] ?? "NIL?")", expected: "\(expectedLongitude)"))
    }
    
    func testTermSearchQueryParams() {
        let expectedTerm = "A test search term"
        let query = YLPSearchQuery(latitude: NSNumber(value: 0), andLongitude: NSNumber(value: 0))
        
        query.term = expectedTerm
        
        let parameters = query.parameters()
        
        XCTAssert(parameters["term"] as? String == expectedTerm,
                  getMessage(field: "term", found: "\(parameters["term"] ?? "NIL?")", expected: expectedTerm))
    }

    func testSortedSearchQueryParams() {
        let expectedSort = "distance"
        let query = YLPSearchQuery(location: "")
        
        let parameters = query.parameters()
        
        XCTAssert(parameters["sort_by"] as? String == expectedSort,
                  getMessage(field: "sort_by", found: "\(parameters["sort_by"] ?? "NIL?")", expected: expectedSort))
    }
}
