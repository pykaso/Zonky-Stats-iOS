//
//  Protocols.swift
//  Zonky Stats
//
//  Created by lgergel on 16/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Swift.Void
    
    //func dataTask(with request: URLRequest, completionHandler: @escaping  DataTaskResult) -> URLSessionDataTaskProtocol
    func dataTask(with url: URL, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol

}

extension URLSession: URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping URLSessionProtocol.DataTaskResult) -> URLSessionDataTaskProtocol {
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
