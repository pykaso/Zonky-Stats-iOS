//
//  Zonky_StatsTests.swift
//  Zonky StatsTests
//
//  Created by lgergel on 16/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import XCTest
@testable import Zonky_Stats

class Zonky_StatsTests: XCTestCase {
    
    let JSON = "[{\"id\": 70741,\"datePublished\": \"2017-01-31T22:42:46.169+01:00\",\"published\": true,\"questionsAllowed\": false}, {\"id\": 70088,\"datePublished\": \"2017-01-31T21:43:21.744+01:00\",\"published\": true, \"questionsAllowed\": false}]".data(using: String.Encoding.utf8)
    
    let JSON_EMPTY = "{}".data(using: String.Encoding.utf8)
    let JSON_ERR = "chyba ..".data(using: String.Encoding.utf8)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMarketplaceResource() {
        let fromD = Date.from(2017, 1, 1)
        let toD = Date.from(2018, 1, 1)
        
        let resource = MarketplaceResource(fromD: fromD!, toD: toD!)
        XCTAssertEqual(resource.fields, "fields=datePublished,covered")
        XCTAssertEqual(resource.methodPath, "/loans/marketplace")
        XCTAssertEqual(resource.queryParams, "fields=datePublished,covered&datePublished__gte=2017-01-01T00:00:00%2B01:00&datePublished__lt=2018-01-01T00:00:00%2B01:00")
        XCTAssertEqual(resource.url.absoluteString, "https://api.zonky.cz/loans/marketplace?fields=datePublished,covered&datePublished__gte=2017-01-01T00:00:00%2B01:00&datePublished__lt=2018-01-01T00:00:00%2B01:00")
        let loans: (Loans?, String?) = resource.makeModel(data: JSON!)
        XCTAssertNotNil(loans.0)
        let empty = resource.makeModel(data: JSON_EMPTY!)
        XCTAssertNil(empty.0)
        XCTAssertNotNil(empty.1)
        XCTAssertEqual(empty.1, "Failed to convert JSON to serializale object.")
        let err  = resource.makeModel(data: JSON_ERR!)
        XCTAssertNil(err.0)
        XCTAssertNotNil(err.1)
        XCTAssertEqual(err.1, "JSON response serialization error.")
        XCTAssertNotNil(resource.setupRequest(config: URLSessionConfiguration.ephemeral))
    }
    
    func testDateExtension() {
        // XCTAssertEqual(Date.tzHome()?.abbreviation(), TimeZone.current.identifier) // ??
        XCTAssertEqual(Date.tzUTC()?.abbreviation(), "GMT")
        let testDate = Date.from(2017, 11, 12)
        XCTAssertEqual(testDate?.toISO(), "2017-11-12T00:00:00+01:00")
        XCTAssertEqual(testDate?.firstDay()?.toISO(), "2017-11-01T00:00:00+01:00")
        XCTAssertEqual(testDate?.toMonthBeg(), "2017-11-01")
    }
    
    func testModel(){
        let agl = AgregatedLoans(interval: "2017-11-01")
        XCTAssertEqual(agl.interval, "2017-11-01")
        XCTAssertEqual(agl.loans, 0)
        XCTAssertEqual(agl.covered, 0)
        let amo = agl.managedObject()
        XCTAssertEqual(amo.interval?.toISO(), "2017-11-01T00:00:00+01:00")
        XCTAssertEqual(amo.key, "2017-11-01")
        XCTAssertEqual(amo.loans, 0)
        XCTAssertEqual(amo.covered, 0)
        
        let loan = Loan(id: "123", datePublished: "2017-11-21T00:00:00+01:00", covered: true)
        XCTAssertEqual(loan.key(), "2017-11-01")
        let dict = ["id":"345", "datePublished":"2017-11-21T00:00:00+01:00", "covered": true] as [String : Any]
        let loan2 = Loan(serialized: dict)
        XCTAssertEqual(loan2.key(), "2017-11-01")
        
        let loans = Loans(items: [loan, loan2])
        XCTAssertEqual(loans.items.count, 2)
        
        let loans2 = Loans(serialization: [dict, dict])
        XCTAssertEqual(loans2.items.count, 2)
    }
    
    func testApiRequest() {
        let session = MockURLSession()
        session.nextData = JSON
        struct TestModel {
            
        }
        
        struct TestResourse: ApiResource {
            let methodPath = "/test/marketplace"
            var queryParams = "test=params"
            func setupRequest(config: URLSessionConfiguration) -> URLSessionConfiguration {
                return config
            }
            func makeModel(serialization: Serializable) -> TestModel {
                return TestModel()
            }
        }
        var request = ApiRequest(resource: TestResourse(), session: session)
        request.load { (response: (TestModel?, String?))  -> Void  in
            XCTAssertNil(response.1)
            XCTAssertNotNil(response.0)
        }
        
        request = ApiRequest(resource: TestResourse(), session: session)
        session.nextError = NSError(domain: "error", code: 0, userInfo: nil)
        request.load { (response: (TestModel?, String?))  -> Void  in
            XCTAssertNil(response.0)
            XCTAssertNotNil(response.1)
            XCTAssertEqual(response.1, "The operation couldn’t be completed. (error error 0.)")
        }
    }
}
