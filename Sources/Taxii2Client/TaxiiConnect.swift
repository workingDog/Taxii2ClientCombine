//
//  TaxiiConnect.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/24.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import Combine


/*
 * represents an error during a connection
 */
enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}

extension String {
    func trim() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/*
 * Base class for network connection to a Taxii-2.x server
 *
 * @param host     the host string
 * @param port     the port number, as an Integer
 * @param protocol the protocol, either http or https (default)
 * @param user     the user login name
 * @param password the user login password
 * @param timeout  in seconds, default 60 seconds
 */
class TaxiiConnect {
    
    let host: String
    let port: Int
    let user: String
    let password: String
    let protokol: String
    let timeout: TimeInterval
    let taxiiVersion: String
    let mediaStix: String
    let mediaTaxii: String
    let sessionManager: URLSession
    
    
    init(host: String, port: Int = -1, user: String, password: String,
         protokol: String = "https", taxiiVersion: String = "2.0", timeout: Double = 60.0) {
        
        self.host = TaxiiConnect.withoutLastSlash(host)
        self.port = port
        self.user = user
        self.password = password
        self.protokol = protokol
        self.taxiiVersion = taxiiVersion
        self.timeout = TimeInterval(timeout)
        if self.taxiiVersion.trim() == "2.1" {
            self.mediaStix  = "application/stix+json;version=2.1"
            self.mediaTaxii = "application/taxii+json;version=2.1"
        } else {
            self.mediaStix  = "application/vnd.oasis.stix+json"
            self.mediaTaxii = "application/vnd.oasis.taxii+json"
        }
        self.sessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = timeout  // seconds
            configuration.timeoutIntervalForResource = timeout // seconds
            return URLSession(configuration: configuration)
        }()
    }
    
    convenience init(url: URL, user: String, password: String, taxiiVersion: String = "2.0", timeout: Int = 60) {
        self.init(host: url.host!, port: url.port ?? -1, user: user, password: password, protokol: url.scheme!)
    }

    convenience init(url: String, user: String, password: String, taxiiVersion: String = "2.0", timeout: Int = 60) {
        self.init(url: URL(string: url)!, user: user, password: password)
    }

    // return the url without the last slash.
    static func withoutLastSlash(_ url: String) -> String {
        return (url.trim().last == "/") ? String(url.trim().dropLast()) : url
    }

    // return the url with a terminating slash.
    static func withLastSlash(_ url: String) -> String {
        return (url.trim().last == "/") ? url.trim() : url.trim() + "/"
    }

    func portString() -> String {
        (String(port).isEmpty || (port == -1)) ? "" : ":" + String(port).trim()
    }
    
    func protocolValue() -> String {
        (protokol.trim().last == ":") ? String(protokol.trim().dropLast(1)) : protokol.trim()
    }
    
    func baseURL() -> String {
        protocolValue().lowercased() + "://" + host.trim() + portString()
    }
    
    func hash() -> String {
        let loginData = String(format: "%@:%@", user, password).data(using: .utf8)!
        return loginData.base64EncodedString()
    }
    
}
