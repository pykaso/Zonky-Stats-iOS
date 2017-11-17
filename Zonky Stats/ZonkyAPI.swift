//
//  ZonkyAPI.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Foundation

protocol ApiResource {
    associatedtype Model
    var methodPath: String { get }
    var queryParams: String { get }
    func makeModel(serialization: Serializable) -> Model
    func setupRequest(config: URLSessionConfiguration) -> URLSessionConfiguration
}

extension ApiResource {
    var url: URL {
        let baseUrl = "https://api.zonky.cz"
        let url = baseUrl + methodPath + "?" + queryParams
        return URL(string: url)!
    }
    
    func makeModel(data: Data) -> (Model?, String?) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return (nil, "JSON response serialization error.")
        }
        guard let jsonSerialization = json as? Serializable else {
            return (nil, "Failed to convert JSON to serializale object.")
        }
        let r = makeModel(serialization: jsonSerialization)
        return (r, nil)
    }
}

struct MarketplaceResource: ApiResource {
    let methodPath = "/loans/marketplace"
    public var from: Date
    public var to: Date
    let fields = "fields=datePublished,covered"
    
    var queryParams: String {
        return fields + "&datePublished__gte=" + from.toISO().urlSafe() + "&datePublished__lt=" + to.toISO().urlSafe()
    }
    
    init(fromD: Date, toD: Date) {
        from = fromD
        to = toD
    }
    
    func makeModel(serialization: Serializable) -> Loans {
        return Loans(serialization: serialization)
    }
    
    func setupRequest(config: URLSessionConfiguration) -> URLSessionConfiguration {
        let headers:[AnyHashable: Any] = ["x-page": "0", "x-size": "9999", "x-order": "datePublished"]
        config.httpAdditionalHeaders = headers
        return config
    }
}

extension String {
    func urlSafe() -> String {
        return self.replacingOccurrences(of: "+", with: "%2B")
    }
}


