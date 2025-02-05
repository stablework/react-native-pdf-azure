//
//  ApiService.swift
//  DocSign
//
//  Created by admin on 1/27/25.
//

import Foundation
import XMLCoder

class ApiService: NSObject, XMLParserDelegate  {
    
    // Shared instance for singleton pattern
    static let shared = ApiService()
    
    private override init() {}
    
    // Variables for XML parsing
    private var containers: [Container] = []
    private var currentContainerName: String = ""
    private var currentContainerEtag: String = ""
    private var currentContainerLeaseStatus: String = ""
    private var currentElement = ""
    
    // Method to fetch the bearer token
    func getStorageBearerToken(tenantID: String, clientID: String, clientSecret: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Construct the URL
        guard let url = URL(string: "https://login.microsoftonline.com/\(tenantID)/oauth2/token") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Set up the body parameters
        let parameters: [String: String] = [
            "grant_type": "client_credentials",
            "client_id": clientID,
            "client_secret": clientSecret,
            "resource": "https://storage.azure.com/"
        ]
        
        // Encode parameters to "x-www-form-urlencoded" format
        let bodyData = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyData.data(using: .utf8)
        
        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ApiError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.noData))
                return
            }
            
            // Parse the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["access_token"] as? String,
                   let expiresOn = json["expires_on"] as? String {
                    
                    // Save to UserDefaults
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(expiresOn, forKey: "expiresOn")
                    UserDefaults.standard.synchronize()
                    
                    completion(.success(()))
                } else {
                    completion(.failure(ApiError.parsingFailed))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func listStorageContents(storageAccountName: String, completion: @escaping (Result<[Container], Error>) -> Void) {
        // Construct the URL
        if !ApiService.shared.isTokenValid() {
            let tenantID = tenantID
            let clientID = clientID
            let clientSecret = clientSecret
            
            ApiService.shared.getStorageBearerToken(tenantID: tenantID, clientID: clientID, clientSecret: clientSecret) { result in
                switch result {
                case .success:
                    self.listStorageContents(storageAccountName: storageAccountName, completion: completion)
                    print("Token refreshed successfully")
                case .failure(let error):
                    completion(.failure(error))
                    print("Failed to refresh token: \(error.localizedDescription)")
                }
            }
            return
        } else {
            print("Token is still valid, no need to refresh")
        }
        
        let urlString = "https://\(storageAccountName).blob.core.windows.net/?comp=list"
        guard let url = URL(string: urlString) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        // Retrieve Bearer Token
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            completion(.failure(ApiError.noData))
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("2017-11-09", forHTTPHeaderField: "x-ms-version")
        request.setValue(currentUTCDateString(), forHTTPHeaderField: "x-ms-date")
        
        // Perform API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ApiError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.noData))
                return
            }
            
            let decoder = XMLDecoder()
            do {
                let enumerationResults = try decoder.decode(EnumerationResults.self, from: data)
                print(enumerationResults)
                completion(.success(enumerationResults.containers.first?.containerName ?? []))
            } catch {
                completion(.failure(ApiError.parsingFailed))
                print("Error decoding XML: \(error)")
            }
//
//            // Parse the XML response
//            self.containers.removeAll()
//            let parser = XMLParser(data: data)
//            parser.delegate = self
//            if parser.parse() {
//                completion(.success(self.containers))
//            } else {
//                completion(.failure(ApiError.parsingFailed))
//            }
        }
        
        task.resume()
    }
    
    // Helper to get current date in ISO 8601 format for x-ms-date
    private func currentISO8601DateString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
    
    // Helper to get current date in ISO 8601 format for x-ms-date
    private func currentUTCDateString() -> String {
        //            Wed, 05 Feb 2025 06:55:10 GMT
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter.string(from: Date())
    }
    
    // XMLParserDelegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        if elementName == "Container" {
            currentContainerName = ""
            currentContainerEtag = ""
            currentContainerLeaseStatus = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        
        switch currentElement {
        case "Name":
            currentContainerName += trimmedString
        case "Etag":
            currentContainerEtag += trimmedString
        case "LeaseStatus":
            currentContainerLeaseStatus += trimmedString
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName == "Container" {
//            let container = Container(
//                name: currentContainerName,
//                etag: currentContainerEtag,
//                leaseStatus: currentContainerLeaseStatus
//            )
//            containers.append(container)
//        }
//        currentElement = ""
    }
    
    // API Errors
    enum ApiError: Error {
        case invalidURL
        case invalidResponse
        case noData
        case parsingFailed
    }
    
    
}

extension ApiService {
    func isTokenValid() -> Bool {
        guard let expiresOn = UserDefaults.standard.string(forKey: "expiresOn"),
              let expirationTime = TimeInterval(expiresOn) else {
            return false // Token does not exist or expiration time is invalid
        }

        let currentTime = Date().timeIntervalSince1970
        return currentTime < expirationTime // Check if the token is still valid
    }
}
