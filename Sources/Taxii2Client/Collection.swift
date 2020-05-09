//
//  Collection.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/22.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import Combine
import GenericJSON


/*
 * This Endpoint provides general information about a Collection, which can be used to help
 * users and clients decide whether and how they want to interact with it.
 *
 * @param conn the connection to the Taxii-2.x server
 */
class Collection {
    
    let taxiiCollection: TaxiiCollection
    let api_root: String
    let conn: TaxiiConnection
    let basePath: String
    let thePath: String
    
    init(taxiiCollection: TaxiiCollection, api_root: String, conn: TaxiiConnection)  {
        self.taxiiCollection = taxiiCollection
        self.api_root = TaxiiConnection.withLastSlash(api_root)
        self.conn = conn
        self.basePath = self.api_root + "collections/" + self.taxiiCollection.id
        self.thePath = self.basePath + "/objects/"
    }

    // taxii-2.0
    func getBundle() -> AnyPublisher<TaxiiBundle?, APIError> {
        return conn.fetchThis(path: thePath, headerType: 1, taxiiType: TaxiiBundle.self)
    }
    
    func getObjects(filters: TaxiiFilters? = nil) -> AnyPublisher<TaxiiEnvelope?, APIError> {
        if let theFilters = filters {
            return conn.fetchThisWithFilters(path: thePath + "objects/", filters: theFilters, taxiiType: TaxiiEnvelope.self)
        } else {
            return conn.fetchThis(path: thePath + "objects/", headerType: 1, taxiiType: TaxiiEnvelope.self)
        }
    }

    func getObject(obj_id: String, filters: TaxiiFilters? = nil) -> AnyPublisher<TaxiiEnvelope?, APIError> {
        if let theFilters = filters {
            return conn.fetchThisWithFilters(path: thePath + obj_id + "/", filters: theFilters, taxiiType: TaxiiEnvelope.self)
        } else {
            return conn.fetchThis(path: thePath + obj_id + "/", headerType: 1, taxiiType: TaxiiEnvelope.self)
        }
    }

    func getObjectVersions(obj_id: String, filters: TaxiiFilters? = nil) ->AnyPublisher<TaxiiVersionResource?, APIError> {
        if let theFilters = filters {
            return conn.fetchThisWithFilters(path: thePath + obj_id + "/versions/", filters: theFilters, taxiiType: TaxiiVersionResource.self)
        } else {
            return conn.fetchThis(path: thePath + obj_id + "/versions/", headerType: 1, taxiiType: TaxiiVersionResource.self)
        }
    }
    
    /*
     * version and spec_version filters only
     */
    func deleteObject(obj_id: String, filters: TaxiiFilters? = nil) -> AnyPublisher<JSON?, APIError> {
        if let theFilters = filters {
            return conn.fetchThisWithFilters(path: thePath + "objects/" + obj_id + "/", filters: theFilters, taxiiType: JSON.self)
        } else {
            return conn.fetchThis(path: thePath + "objects/" + obj_id + "/", headerType: 1, taxiiType: JSON.self)
        }
    }

    // returns the raw json data
    func getRaw() -> AnyPublisher<Data, APIError> {
        return conn.fetchRaw(path: thePath, headerType: 1)
    }
 
    func getManifests(filters: TaxiiFilters? = nil) -> AnyPublisher<TaxiiManifestRecord?, APIError> {
        if let theFilters = filters {
            return conn.fetchThisWithFilters(path: thePath + "manifest/", filters: theFilters, taxiiType: TaxiiManifestRecord.self)
        } else {
            return conn.fetchThis(path: thePath + "manifest/", taxiiType: TaxiiManifestRecord.self)
        }
    }

    // taxii-2.0
    func addObjects(bundle: TaxiiBundle) -> AnyPublisher<TaxiiStatus?, APIError> {
        let jsonData = (try? JSONSerialization.data(withJSONObject: bundle)) ?? Data()
        return conn.postThis(path: thePath, jsonData: jsonData, taxiiType: TaxiiStatus.self)
    }
    
    func addObjects(envelope: TaxiiEnvelope) -> AnyPublisher<TaxiiStatus?, APIError> {
        let jsonData = (try? JSONSerialization.data(withJSONObject: envelope)) ?? Data()
        return conn.postThis(path: thePath, jsonData: jsonData, taxiiType: TaxiiStatus.self)
    }
      
}
