//
//  Status.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/22.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import Combine


/*
 * This Endpoint provides information about the status of a previous request.
 *
 * @param conn the connection to the Taxii-2.x server
 */
class Status {
    
    let api_root: String
    let status_id: String
    let conn: TaxiiConnection
    let thePath: String
    
    init(api_root: String, status_id: String, conn: TaxiiConnection) {
        self.api_root = TaxiiConnection.withLastSlash(api_root)
        self.status_id = status_id
        self.conn = conn
        self.thePath = self.api_root + "status/" + self.status_id + "/"
    }

    func get() -> AnyPublisher<TaxiiStatus?, APIError> {
        return conn.fetchThis(path: thePath, taxiiType: TaxiiStatus.self)
    }
    
}
