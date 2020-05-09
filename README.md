# TAXII 2.1 client library in Swift using the Combine framework

### Status
work in progress, not yet ready


**Taxii2Client** is a Swift library that provides a set of classes and methods for building clients to [TAXII-2.1](https://oasis-open.github.io/cti-documentation/) servers.

[[1]](https://oasis-open.github.io/cti-documentation/) 
Trusted Automated Exchange of Intelligence Information (TAXII) is an application layer protocol 
used to exchange cyber threat intelligence (CTI) over HTTPS. 
TAXII enables organizations to share CTI by defining an API that aligns with common sharing models.
[TAXII-2.1](https://oasis-open.github.io/cti-documentation/) defines the TAXII RESTful API and its resources along with the requirements for TAXII Client and Server implementations. 


**Taxii2Client** uses asynchronous requests to fetch TAXII 2.1 server resources. 
It provides the following endpoints:

- *Server*, endpoint for retrieving the discovery and api roots resources.
- *ApiRoot*, endpoint for retrieving the api roots resources.
- *Collections*, endpoint for retrieving the list of collection resources. 
- *Collection*, endpoint for retrieving a collection resource and associated objects. 
- *Status*, endpoint for retrieving a status resource. 

### Usage

The following TAXII 2.1 API services are supported with these corresponding async methods. Each method returns a Combine framework Publisher.

- Server Discovery --> server.discovery 
- Get API Root Information --> server.getApiroots()
- Get Collections --> collections.get() and collections.get(index)
- Get Object Manifests --> collection.getManifests()
- Get Status --> status.get()
- Add Objects --> collection.addObjects(envelope) and collection.addObject(bundle) for TAXII-2.0  
- Get Objects --> collection.getObjects() and getBundle() for TAXII-2.0 

(NOTE: the objects returned from getBundle() and getObjects() consist of JSON constructs, not Swift STIX-2 class objects)

The class *TaxiiConnection* provides the async communication to the server.

Example:

    import Taxii2Client
    import Combine
 
    // taxii-2.0
    let conn = TaxiiConnection(host: "cti-taxii.mitre.org", user: "", password: "", taxiiVersion: "2.0")
    let taxiiServer = Server(conn: conn)
    cancellable = taxiiServer.discovery()
        .sink(receiveCompletion: { _ in },
                receiveValue: { discovery in
                print("---> discovery: \(discovery as Optional)")
        })
    }

See the [TAXII 2.1 Specification](https://oasis-open.github.io/cti-documentation/) for the list 
of attributes of the TAXII 2.1 server responses.

### Installation 

#### Swift Package Manager

Create a Package.swift file for your project and add a dependency to:

    dependencies: [
      .package(url: "https://github.com/workingDog/Taxii2ClientCombine.git", from: "0.0.1")
    ]

#### Using Xcode

Select File > Swift Packages > Add Package Dependency...,
"https://github.com/workingDog/Taxii2ClientCombine.git"

### Dependencies and requirements

**Taxii2Client** depends on the following library:

- [GenericJSON](https://github.com/zoul/generic-json-swift)

Requires Swift 5

### References
 
1) [TAXII 2.1 Specification](https://oasis-open.github.io/cti-documentation/resources#taxii-21-specification)

