//
//  ApiRoot.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/22.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import Combine


/*
 * This Endpoint provides general information about an API Root,
 * which can be used to help users and clients decide whether and how they want to interact with it.
 *
 * @param api_root the api_root path of this ApiRoot request
 * @param conn     the connection to the Taxii-2.x server
 */
class ApiRoot {
    
    let api_root: String
    let conn: TaxiiConnection
    
    init(api_root: String, conn: TaxiiConnection) {
        self.api_root = TaxiiConnection.withLastSlash(api_root)
        self.conn = conn
    }
    
    func get() -> AnyPublisher<TaxiiApiRoot?, APIError> {
        return conn.fetchThis(path: api_root, taxiiType: TaxiiApiRoot.self)
    }

    func collections() -> AnyPublisher<TaxiiCollections?, APIError> {
        return Collections(api_root: api_root, conn: conn).get()
    }
    
    func collections(index: Int) -> AnyPublisher<TaxiiCollection?, APIError> {
        return self.collections().map { $0?.collections?[index] }.eraseToAnyPublisher()
    }
    
    func status(status_id: String) -> AnyPublisher<TaxiiStatus?, APIError> {
        return Status(api_root: api_root, status_id: status_id, conn: conn).get()
    }
    
}

