//
//  TaxiiProtocol.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/21.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import GenericJSON

// TAXII-2.1 protocol


/*
* helper to make a UInt64 when reading various json representation, especialy string
*/
struct TaxiiInt: Codable {
    let value: UInt64

    init(_ value: UInt64) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let uint = try? container.decode(UInt64.self) {
            value = uint
        } else if let int = try? container.decode(Int.self) {
            value = UInt64(int)
        } else if let double = try? container.decode(Double.self) {
            value = UInt64(double)
        } else if let str = try? container.decode(String.self) {
            value = UInt64(str) ?? 0
        } else {
            throw DecodingError.typeMismatch(UInt64.self, .init(codingPath: decoder.codingPath, debugDescription: ""))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

/*
 * The discovery resource contains information about a TAXII Server,
 * such as a human-readable title, description, and contact information,
 * as well as a list of API Roots that it is advertising.
 * It also has an indication of which API Root it considers the default,
 * or the one to use in the absence of other information/user choice.
 */
struct TaxiiDiscovery: Identifiable, Codable, Equatable, Comparable {
    
    let id = UUID().uuidString
    let title: String
    let description: String?
    let contact: String?
    let default_api: String?
    let api_roots: [String]?
     
    init() {
        self.title = ""
        self.description = ""
        self.contact = ""
        self.default_api = ""
        self.api_roots = []
    }
    
    private enum CodingKeys : String, CodingKey {
        case title, default_api = "default", description, contact, api_roots
    }
    
    public static func == (lhs: TaxiiDiscovery, rhs: TaxiiDiscovery) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiDiscovery, rhs: TaxiiDiscovery) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The api-root resource contains general information about the API Root,
 * such as a human-readable title and description, the TAXII versions it supports,
 * and the maximum size of the content body it will accept in a PUT or POST (max_content_length).
 */
struct TaxiiApiRoot: Identifiable, Codable, Equatable, Comparable {
    
    let id = UUID().uuidString
    let title: String
    let versions: [String]
    let max_content_length: TaxiiInt   // should be UInt64, but sometimes it is a String
    let description: String?
  
    public static func == (lhs: TaxiiApiRoot, rhs: TaxiiApiRoot) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiApiRoot, rhs: TaxiiApiRoot) -> Bool {
        lhs.id < rhs.id
    }
}

/* Taxii-2.0 only
 * This type represents an object that was not added to the Collection.
 */
struct TaxiiStatusFailure: Identifiable, Codable, Equatable, Comparable {
    
    let id: String
    let message: [String]?
    
    public static func == (lhs: TaxiiStatusFailure, rhs: TaxiiStatusFailure) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiStatusFailure, rhs: TaxiiStatusFailure) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * This type represents an object that was not added to the Collection.
 */
struct TaxiiStatusDetails: Identifiable, Codable, Equatable, Comparable {
    
    let id: String
    let version: String
    let message: [String]?
    
    public static func == (lhs: TaxiiStatusDetails, rhs: TaxiiStatusDetails) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiStatusDetails, rhs: TaxiiStatusDetails) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The status resource represents information about a request to add objects to a Collection.
 */
struct TaxiiStatus: Identifiable, Codable, Equatable, Comparable {
    
    let id: String
    let status: String
    let total_count: TaxiiInt
    let success_count: TaxiiInt
    let failure_count: TaxiiInt
    let pending_count: TaxiiInt
    let request_timestamp: String?
    let failures: [TaxiiStatusDetails]?
    let pendings: [TaxiiStatusDetails]?
    let successes: [TaxiiStatusDetails]?
    
    public static func == (lhs: TaxiiStatus, rhs: TaxiiStatus) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiStatus, rhs: TaxiiStatus) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The error message is provided by TAXII Servers in the response body when
 * returning an HTTP error status and contains more information describing the error,
 * including a human-readable title and description, an error_code and error_id,
 * and a details structure to capture further structured information about the error.
 */
struct TaxiiErrorMessage: Identifiable, Codable, Equatable, Comparable {
    
    let id = UUID().uuidString
    let title: String
    let description: [String]?
    let error_id: [String]?
    let error_code: [String]?
    let http_status: [String]?
    let external_details: [String]?
    let details: [String:String]?
    
    public static func == (lhs: TaxiiErrorMessage, rhs: TaxiiErrorMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiErrorMessage, rhs: TaxiiErrorMessage) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The collection resource contains general information about a Collection,
 * such as its id, a human-readable title and description,
 * an optional list of supported media_types
 * (representing the media type of objects can be requested from or added to it),
 * and whether the TAXII Client, as authenticated, can get objects from
 * the Collection and/or add objects to it.
 */
struct TaxiiCollection: Identifiable, Codable, Equatable, Comparable {
    
    let id: String
    let title: String
    let can_read: Bool
    let can_write: Bool
    let description: String?
    let alias: String?
    let media_types: [String]?
    
    public static func == (lhs: TaxiiCollection, rhs: TaxiiCollection) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiCollection, rhs: TaxiiCollection) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The collections resource is a simple wrapper around a list of collection resources.
 */
struct TaxiiCollections: Identifiable, Codable, Equatable, Comparable {
    
    let id = UUID().uuidString
    let collections: [TaxiiCollection]?
    
    public static func == (lhs: TaxiiCollections, rhs: TaxiiCollections) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiCollections, rhs: TaxiiCollections) -> Bool {
        lhs.id < rhs.id
    }
}

/* Taxii-2.0 only
 * The manifest-entry type captures metadata about a single object, indicated by the id property.
 */
struct TaxiiManifestEntry: Identifiable, Codable, Equatable, Comparable {
    
    let id: String
    let date_added: [String]?
    let versions: [String]?
    let media_types: [String]?
    
    public static func == (lhs: TaxiiManifestEntry, rhs: TaxiiManifestEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiManifestEntry, rhs: TaxiiManifestEntry) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The manifest-record type captures metadata about a single object, indicated by the id property.
 */
struct TaxiiManifestRecord: Identifiable, Codable, Equatable, Comparable {
    
    let id: String
    let date_added: [String]
    let versions: [String]
    let media_types: [String]?
    
    public static func == (lhs: TaxiiManifestRecord, rhs: TaxiiManifestRecord) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiManifestRecord, rhs: TaxiiManifestRecord) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The URL Filtering Parameters
 */
struct TaxiiFilters: Codable {
    
    let added_after: String?
    let limit: Int?
    let next: String?
    let id: [String]?
    let type: [String]?
    let version: [String]?
    let spec_version: [String]?
    
    init(added_after: String? = nil, limit: Int? = nil, next: String? = nil, id: [String]? = nil, type: [String]? = nil,
         version: [String]? = nil, spec_version: [String]? = nil) {
        self.added_after = added_after
        self.limit = limit
        self.next = next
        self.id = id
        self.type = type
        self.version = version
        self.spec_version = spec_version
    }
    
    func asParameters() -> [String:String] {
        var params = [String:String]()
        
        if self.added_after != nil { params["added_after"] = added_after }
        if self.limit != nil { params["limit"] = "\(limit!)" }
        if self.next != nil { params["next"] = next }

        if self.id != nil {
            params["match[id]"] = self.id!.joined(separator: ",")
        }
        if self.type != nil {
            params["match[type]"] = self.type!.joined(separator: ",")
        }
        if self.version != nil {
            params["match[version]"] = self.version!.joined(separator: ",")
        }
        if self.spec_version != nil {
            params["match[spec_version]"] = self.spec_version!.joined(separator: ",")
        }

        return params
    }
}

/*
 * The manifest resource is a simple wrapper around a list of manifest-record items.
 */
struct TaxiiManifestResource: Identifiable, Codable, Equatable, Comparable {
    
    let id = UUID().uuidString
    let more: Bool?
    let objects: [TaxiiManifestRecord]?
    
    public static func == (lhs: TaxiiManifestResource, rhs: TaxiiManifestResource) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiManifestResource, rhs: TaxiiManifestResource) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The versions resource is a simple wrapper around a list of versions.
 */
struct TaxiiVersionResource: Identifiable, Codable, Equatable, Comparable {
    
    let id = UUID().uuidString
    let more: Bool?
    let versions: [String]?
    
    public static func == (lhs: TaxiiVersionResource, rhs: TaxiiVersionResource) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiVersionResource, rhs: TaxiiVersionResource) -> Bool {
        lhs.id < rhs.id
    }
}

/* Taxii-2.0 only
 * The bundle is a simple wrapper for STIX 2.0 content.
 */
struct TaxiiBundle: Identifiable, Codable, Equatable, Comparable {
    
    let type: String
    let id: String
    let spec_version: String
    let objects: [JSON]?

    public static func == (lhs: TaxiiBundle, rhs: TaxiiBundle) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiBundle, rhs: TaxiiBundle) -> Bool {
        lhs.id < rhs.id
    }
}

/*
 * The envelope is a simple wrapper for STIX 2.1 content.
 * When returning STIX 2.1 content in a TAXII-2.1 response the HTTP root object payload MUST be an envelope.
 */
struct TaxiiEnvelope: Identifiable, Codable, Equatable, Comparable {
    
    let id = UUID().uuidString
    let more: Bool?
    let next: String?
    let objects: [JSON]?
    
    public static func == (lhs: TaxiiEnvelope, rhs: TaxiiEnvelope) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TaxiiEnvelope, rhs: TaxiiEnvelope) -> Bool {
        lhs.id < rhs.id
    }
}
