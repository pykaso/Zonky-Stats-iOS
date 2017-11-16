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
    func makeModel(serialization: Serializable) -> ApiResponse<Model>
    func setupRequest(config: URLSessionConfiguration) -> URLSessionConfiguration
}

struct ApiResponse<Model> {
    var model: Model?
    var error: String?
    
    init(_ model: Model?, _ error: String?) {
        self.model = model
        self.error = error
    }
}

extension ApiResource {
    var url: URL {
        let baseUrl = "https://api.zonky.cz"
        let url = baseUrl + methodPath + "?" + queryParams
        return URL(string: url)!
    }
    
    func makeModel(data: Data) -> ApiResponse<Model> {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return ApiResponse(nil, "JSON response serialization error.")
        }
        guard let jsonSerialization = json as? Serializable else {
            return ApiResponse(nil, "Failed to convert JSON to serializale object.")
        }
        return makeModel(serialization: jsonSerialization)
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
    
    func makeModel(serialization: Serializable) -> ApiResponse<Loans> {
        let loans = Loans(serialization: serialization)
        return ApiResponse(loans, nil)
        //return ApiResponse(nil, "Test chyby")
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


