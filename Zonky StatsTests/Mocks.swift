//
//  Mocks.swift
//  Zonky StatsTests
//
//  Created by lgergel on 16/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Foundation
@testable import Zonky_Stats

//MARK: MOCK
class MockURLSession: URLSessionProtocol {
    
    
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func successHttpURLResponse(_ url: URL) -> URLResponse {
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with url: URL, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = url
        completionHandler(nextData, successHttpURLResponse(url), nextError)
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}
