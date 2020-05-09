//
//  Collections.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/22.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import Combine


/*
 * This Endpoint provides information about the Collections hosted under this API Root.
 *
 * @param conn the connection to the Taxii-2.x server
 */
class Collections {
    
    let api_root: String
    let conn: TaxiiConnection
    let thePath: String
    
    init(api_root: String, conn: TaxiiConnection)  {
        self.api_root = TaxiiConnection.withLastSlash(api_root)
        self.conn = conn
        self.thePath = self.api_root + "collections/"
    }
    
    func get() -> AnyPublisher<TaxiiCollections?, APIError> {
        return conn.fetchThis(path: thePath, taxiiType: TaxiiCollections.self)
    }
    
    func get(index: Int) -> AnyPublisher<TaxiiCollection?, APIError> {
        return self.get().map { $0?.collections?[index] }.eraseToAnyPublisher()
    }
    
    func getRaw() -> AnyPublisher<Data, APIError> {
        return conn.fetchRaw(path: thePath)
    }
    
}
