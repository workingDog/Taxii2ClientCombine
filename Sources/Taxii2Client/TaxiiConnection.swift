//
//  TaxiiConnection.swift
//  Taxii2Client
//
//  Created by Ringo Wathelet on 2020/03/21.
//  Copyright © 2020 Ringo Wathelet. All rights reserved.
//

import Foundation
import Combine


/*
 * a network connection to a Taxii-2.x server
 */
class TaxiiConnection: TaxiiConnect {
    
    /*
     * fetch data from the server. A GET to the chosen path is sent to the Taxii-2.x server.
     * The TAXII server response is parsed then converted to a Taxii-2.x protocol resource.
     *
     * @param path the full path to the server resource
     * @param headerType with value = 0 (default) for request media type for stix resources,
     *                        value=1 for request media type for taxii resources
     * @return a AnyPublisher<T?, APIError>
     */
    func fetchThis<T: Decodable>(path: String, headerType: Int = 0, taxiiType: T.Type) -> AnyPublisher<T?, APIError> {
        
        let mediaType = headerType == 1 ? mediaStix : mediaTaxii
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(taxiiVersion, forHTTPHeaderField: "version")
        request.addValue("Basic \(hash())", forHTTPHeaderField: "Authorization")
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    /*
     * fetch data from the server. A GET to the chosen path with the defined parameters is sent to the Taxii-2.x server.
     * The TAXII server response is parsed then converted to a Taxii-2.x protocol resource.
     *
     * @param path the full path to the server resource
     * @param filters the filters to apply the the query
     * @param headerType with value = 0 (default) for request media type for stix resources,
     *                        value=1 for request media type for taxii resources
     * @return AnyPublisher<T?, APIError>
     */
    func fetchThisWithFilters<T: Decodable>(path: String, filters: TaxiiFilters, headerType: Int = 0, taxiiType: T.Type) -> AnyPublisher<T?, APIError> {
        
        let params: [String:String] = filters.asParameters()
        let mediaType = headerType == 1 ? mediaStix : mediaTaxii
        
        var components = URLComponents(string: path)!
        components.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(taxiiVersion, forHTTPHeaderField: "version")
        request.addValue("Basic \(hash())", forHTTPHeaderField: "Authorization")
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    /*  
     * post data to the server. A POST to the chosen path is sent to the Taxii-2.x server.
     * The TAXII server response is parsed then converted to a Taxii-2.x protocol resource.
     *
     * @param path the full path to the server resource
     * @param json the JSON data
     * @return Promise
     */
    func postThis<T: Decodable>(path: String, jsonData: Data, taxiiType: T.Type) -> AnyPublisher<T?, APIError> {
        
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(taxiiVersion, forHTTPHeaderField: "version")
        request.addValue("Basic \(hash())", forHTTPHeaderField: "Authorization")
        request.addValue(mediaTaxii, forHTTPHeaderField: "Accept")
        request.addValue(mediaStix, forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return self.doDataTaskPublish(request: request)
    }
    
    /*
     * fetch data from the server. A GET to the chosen path is sent to the Taxii-2.x server.
     * The TAXII server response is returned as raw Data.
     *
     * @param path the full path to the server resource
     * @param headerType with value = 0 (default) for request media type for stix resources,
     *                        value=1 for request media type for taxii resources
     * @return AnyPublisher<Data, APIError>
     */
    func fetchRaw(path: String, headerType: Int = 0) -> AnyPublisher<Data, APIError> {
        
        let mediaType = headerType == 1 ? mediaStix : mediaTaxii
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(taxiiVersion, forHTTPHeaderField: "version")
        request.addValue("Basic \(hash())", forHTTPHeaderField: "Authorization")
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.sessionManager.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                if (httpResponse.statusCode == 401) {
                    throw APIError.apiError(reason: "Unauthorized");
                }
                if (httpResponse.statusCode == 403) {
                    throw APIError.apiError(reason: "Resource forbidden");
                }
                if (httpResponse.statusCode == 404) {
                    throw APIError.apiError(reason: "Resource not found");
                }
                if (405..<500 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "client error");
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "server error");
                }
                return data
        }
        .mapError { error in
            // return the APIError type error
            if let error = error as? APIError {
                return error
            }
            // a URLError, convert it to APIError type error
            if let urlerror = error as? URLError {
                return APIError.networkError(from: urlerror)
            }
            // unknown error condition
            return APIError.unknown
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
   
    private func doDataTaskPublish<T: Decodable>(request: URLRequest) -> AnyPublisher<T?, APIError> {
        return self.sessionManager.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                if (httpResponse.statusCode == 401) {
                    throw APIError.apiError(reason: "Unauthorized");
                }
                if (httpResponse.statusCode == 403) {
                    throw APIError.apiError(reason: "Resource forbidden");
                }
                if (httpResponse.statusCode == 404) {
                    throw APIError.apiError(reason: "Resource not found");
                }
                if (405..<500 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "client error");
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "server error");
                }
                return try? JSONDecoder().decode(T.self, from: data)
        }
        .mapError { error in
            // return the APIError type error
            if let error = error as? APIError {
                return error
            }
            // a URLError, convert it to APIError type error
            if let urlerror = error as? URLError {
                return APIError.networkError(from: urlerror)
            }
            // unknown error condition
            return APIError.unknown
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
}
