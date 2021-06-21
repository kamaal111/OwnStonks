//
//  Endpoint.swift
//  
//
//  Created by Kamaal M Farah on 21/06/2021.
//

import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

    private let baseURL = URL(staticString: "http://127.0.0.1:8000")

    init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }

    var url: URL {
        let urlWithPath = baseURL.appendingPathComponent("/\(path)")
        guard var components = URLComponents(string: urlWithPath.absoluteString) else {
            fatalError("Could not initialize components")
        }
        components.queryItems = queryItems
        guard let componentsURL = components.url else {
            fatalError("Invalid URL components: \(components)")
        }
        return componentsURL
    }

    static func info(of symbols: String, with queryItems: [URLQueryItem] = []) -> Self {
        Endpoint(path: "info/\(symbols)", queryItems: queryItems)
    }
}
