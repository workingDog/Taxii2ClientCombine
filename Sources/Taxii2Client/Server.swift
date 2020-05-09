//
//  Server.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/21.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import Combine

/*
 * This Endpoint provides general information about a Taxii-2.0 Server, including the advertised API Roots.
 *
 * @param path    the path to the TAXII server discovery endpoint, default "/taxii/"
 * @param conn    the connection to the Taxii-2.x server
 */
class Server {
    
    let path: String
    let conn: TaxiiConnection
    
    init(conn: TaxiiConnection) {
        if conn.taxiiVersion.trim() == "2.1" {
            self.path = TaxiiConnection.withLastSlash("/taxii2/")
            self.conn = conn
        } else {
            self.path = TaxiiConnection.withLastSlash("/taxii/")
            self.conn = conn
        }
    }
    
    func discovery() -> AnyPublisher<TaxiiDiscovery?, APIError> {
        return conn.fetchThis(path: conn.baseURL() + path, taxiiType: TaxiiDiscovery.self)
    }
    
    // returns the discovered api-root strings
    func getApirootStrings() -> AnyPublisher<[String], APIError> {
        return self.discovery().map {
            $0?.api_roots == nil ? [] : $0!.api_roots!
        }.eraseToAnyPublisher()
    }
    
    // returns all the discovered api-roots
    func getApiroots() -> AnyPublisher<[TaxiiApiRoot], APIError> {
        let disco = self.discovery()
        let discoResult = disco.compactMap { $0 }
        return discoResult.flatMap { (res: TaxiiDiscovery) -> AnyPublisher<[TaxiiApiRoot], APIError>  in
            if let apiroots = res.api_roots {
                return self.getAllRoots(from: apiroots)
            } else {
                return Just([TaxiiApiRoot]()).mapError({ _ in APIError.unknown }).eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
    
    private func getAllRoots(from disc: [String]) ->AnyPublisher<[TaxiiApiRoot], APIError> {
        // create all the publishers
        let apiPubs = disc.map { ApiRoot(api_root: $0, conn: self.conn).get().compactMap{$0}.eraseToAnyPublisher() }
        // create a publisher of publishers
        let pubPubs = Publishers.Sequence<[AnyPublisher<TaxiiApiRoot, APIError>], APIError>(sequence: apiPubs)
        // collect the results once all completed
        return pubPubs.flatMap { $0 }.collect().eraseToAnyPublisher()
    }
    
}
