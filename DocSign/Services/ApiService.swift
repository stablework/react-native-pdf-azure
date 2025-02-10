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
                let enumerationResults = try decoder.decode(EnumerationContainerResults.self, from: data)
                completion(.success(enumerationResults.containers.containerName ?? []))
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
    
    func listStorageBlobsContent(storageAccountName: String, containerName: String, completion: @escaping (Result<EnumerationBlobResults, Error>) -> Void) {
        // Construct the URL
        if !ApiService.shared.isTokenValid() {
            let tenantID = tenantID
            let clientID = clientID
            let clientSecret = clientSecret
            
            ApiService.shared.getStorageBearerToken(tenantID: tenantID, clientID: clientID, clientSecret: clientSecret) { result in
                switch result {
                case .success:
                    self.listStorageBlobsContent(storageAccountName: storageAccountName, containerName: containerName, completion: completion)
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
//        https://{{storageaccountname}}.blob.core.windows.net/{{containername}}?restype=container&comp=list
        let urlString = "https://\(storageAccountName).blob.core.windows.net/\(containerName)?restype=container&comp=list"
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
                let enumerationResults = try decoder.decode(EnumerationBlobResults.self, from: data)
                completion(.success(enumerationResults))
            } catch {
                completion(.failure(ApiError.parsingFailed))
                print("Error decoding XML: \(error)")
            }
        }
        
        task.resume()
    }
    
    func PDFDownLoad(storageAccountName: String, containerName: String, blobName:String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Construct the URL
        if !appDelegate.internetIsAvailable{
            displayAlertWithMessage("No Internet Connection!!")
            hideIndicator()
            return
        }
        if !ApiService.shared.isTokenValid() {
            let tenantID = tenantID
            let clientID = clientID
            let clientSecret = clientSecret
            
            ApiService.shared.getStorageBearerToken(tenantID: tenantID, clientID: clientID, clientSecret: clientSecret) { result in
                switch result {
                case .success:
                    self.PDFDownLoad(storageAccountName: storageAccountName, containerName: containerName, blobName:blobName, completion: completion)
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
//        https://{{storageaccountname}}.blob.core.windows.net/{{containername}}/{{blobname}}.pdf
        let urlString = "https://\(storageAccountName).blob.core.windows.net/\(containerName)/\(blobName)"
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
        request.setValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        request.setValue("*.mp4", forHTTPHeaderField: "Content-Type")
        
        // Create a custom URLSessionConfiguration
        let configuration = URLSessionConfiguration.default

        // Set timeout for a single request (e.g., 30 seconds)
        configuration.timeoutIntervalForRequest = 30.0  // Timeout for individual requests

        // Set timeout for the entire resource (e.g., 60 seconds)
        configuration.timeoutIntervalForResource = 60.0  // Timeout for downloading the full resource

        // Create a URLSession with the custom configuration
        let session = URLSession(configuration: configuration)
        
        // Perform API call
        let task = session.dataTask(with: request) { data, response, error in
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
            completion(.success(data))
        }
        
        task.resume()
    }
    
    func deletePDF(storageAccountName: String, containerName: String, blobName:String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Construct the URL
        if !ApiService.shared.isTokenValid() {
            let tenantID = tenantID
            let clientID = clientID
            let clientSecret = clientSecret
            
            ApiService.shared.getStorageBearerToken(tenantID: tenantID, clientID: clientID, clientSecret: clientSecret) { result in
                switch result {
                case .success:
                    self.deletePDF(storageAccountName: storageAccountName, containerName: containerName, blobName:blobName, completion: completion)
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
        let urlString = "https://\(storageAccountName).blob.core.windows.net/\(containerName)/\(blobName)"
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
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("2017-11-09", forHTTPHeaderField: "x-ms-version")
        request.setValue(currentUTCDateString(), forHTTPHeaderField: "x-ms-date")
        request.setValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        request.setValue("*.mp4", forHTTPHeaderField: "Content-Type")
        
        // Create a custom URLSessionConfiguration
        let configuration = URLSessionConfiguration.default

        // Set timeout for a single request (e.g., 30 seconds)
        configuration.timeoutIntervalForRequest = 30.0  // Timeout for individual requests

        // Set timeout for the entire resource (e.g., 60 seconds)
        configuration.timeoutIntervalForResource = 60.0  // Timeout for downloading the full resource

        // Create a URLSession with the custom configuration
        let session = URLSession(configuration: configuration)
        
        // Perform API call
        let task = session.dataTask(with: request) { data, response, error in
            print(response)
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ApiError.invalidResponse))
                return
            }
            completion(.success(true))
        }
        
        task.resume()
    }
    
    func uploadPDF(storageAccountName: String, containerName: String, blobName:String, completion: @escaping (Result<String, Error>) -> Void){
        if !appDelegate.internetIsAvailable{
            displayAlertWithMessage("No Internet Connection!!")
            hideIndicator()
            return
        }
        
        if !ApiService.shared.isTokenValid() {
            let tenantID = tenantID
            let clientID = clientID
            let clientSecret = clientSecret
            
            ApiService.shared.getStorageBearerToken(tenantID: tenantID, clientID: clientID, clientSecret: clientSecret) { result in
                switch result {
                case .success:
                    self.uploadPDF(storageAccountName: storageAccountName, containerName: containerName, blobName:blobName, completion: completion)
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
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        body += Data("--\(boundary)\r\n".utf8)
        body += Data("Content-Disposition:form-data; name=\"\(blobName)\"".utf8)
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(containerName+(blobName.replacingOccurrences(of: "/", with: "")))
        
        if let fileContent = try? Data(contentsOf: fileURL) {
          body += Data("; filename=\"\(blobName)\"\r\n".utf8)
          body += Data("Content-Type: \"content-type header\"\r\n".utf8)
          body += Data("\r\n".utf8)
          body += fileContent
          body += Data("\r\n".utf8)
        }
        
        body += Data("--\(boundary)--\r\n".utf8);
        let postData = body

        let urlString = "https://\(storageAccountName).blob.core.windows.net/\(containerName)/\(blobName)"
        guard let url = URL(string: urlString) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        // Retrieve Bearer Token
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            completion(.failure(ApiError.noData))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "PUT"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("2017-11-09", forHTTPHeaderField: "x-ms-version")
        request.setValue(currentUTCDateString(), forHTTPHeaderField: "x-ms-date")
        request.setValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        request.setValue("*.mp4", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        if let fileContent = try? Data(contentsOf: fileURL) {
            request.httpBody = fileContent
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(response)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ApiError.invalidResponse))
                return
            }
            
            completion(.success(""))
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
