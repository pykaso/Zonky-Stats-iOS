//
//  ApiRequest.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Foundation

protocol NetworkRequest: class {
    associatedtype Model
    func load(withCompletion completion: @escaping (_ data: Model?, _ error: String?) -> Void)
    func decode(_ data: Data) -> (Model?, String?)
    func getSession() -> URLSessionProtocol
}

extension NetworkRequest {
    fileprivate func load(_ url: URL, withCompletion completion: @escaping (_ data: Model?, _ error: String?) -> Void) {
        let urlsession = getSession()
        let task = urlsession.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                completion(nil, error?.localizedDescription)
                return
            }
            guard let data = data else {
                completion(nil, "No data from server")
                return
            }
            
            let decoded = self.decode(data)
            completion(decoded.0, decoded.1)
            return
        })
        task.resume()
    }
}

class ApiRequest<Resource: ApiResource> {
    let resource: Resource
    let session: URLSessionProtocol
    
    init(resource: Resource, session: URLSessionProtocol) {
        self.resource = resource
        self.session = session
    }
}

extension ApiRequest: NetworkRequest {
    
    func decode(_ data: Data) -> (Model?, String?) {
        let r = resource.makeModel(data: data)
        return (r.0, r.1)
    }
    
    func load(withCompletion completion: @escaping (_ data: Resource.Model?, _ error: String?) -> Void) {
        load(resource.url, withCompletion: completion)
    }
    

    func getSession() -> URLSessionProtocol {
        return session
    }
}
