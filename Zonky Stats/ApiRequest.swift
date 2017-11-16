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
    func load(withCompletion completion: @escaping (ApiResponse<Model>) -> Void)
    func decode(_ data: Data) -> ApiResponse<Model>
    func getSession() -> URLSession?
}

extension NetworkRequest {
    fileprivate func load(_ url: URL, withCompletion completion: @escaping (ApiResponse<Model>) -> Void) {
        if let urlsession = getSession(){
            let task = urlsession.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                guard let data = data else {
                    completion(ApiResponse(nil, error?.localizedDescription))
                    return
                }
                completion(self.decode(data))
            })
            task.resume()
        } else {
            //throw CustomNSError("URLSession not configured")
        }
    }
}

class ApiRequest<Resource: ApiResource> {
    let resource: Resource
    let session: URLSession
    
    init(resource: Resource, session: URLSession) {
        self.resource = resource
        self.session = session
    }
}

extension ApiRequest: NetworkRequest {
    func decode(_ data: Data) -> ApiResponse<Model> {
        return resource.makeModel(data: data)
    }
    
    func load(withCompletion completion: @escaping (ApiResponse<Resource.Model>) -> Void) {
        load(resource.url, withCompletion: completion)
    }
    

    func getSession() -> URLSession? {
        return session
    }
}
