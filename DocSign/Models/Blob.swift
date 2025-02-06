//
//  Blob.swift
//  DocSign
//
//  Created by Hashmob on 06/02/25.
//

import Foundation

// Define the BlobProperties model for the properties of each Blob
struct BlobProperties: Codable {
    let creationTime: String
    let lastModified: String
    let etag: String
    let contentLength: Int
    let contentType: String
    let contentEncoding: String?
    let contentLanguage: String?
    let contentMD5: String
    let cacheControl: String?
    let contentDisposition: String?
    let blobType: String
    let accessTier: String
    let accessTierInferred: Bool
    let leaseStatus: String
    let leaseState: String
    let serverEncrypted: Bool
    
    // Key mapping for XML tags to Swift property names
    private enum CodingKeys: String, CodingKey {
        case creationTime = "Creation-Time"
        case lastModified = "Last-Modified"
        case etag = "Etag"
        case contentLength = "Content-Length"
        case contentType = "Content-Type"
        case contentEncoding = "Content-Encoding"
        case contentLanguage = "Content-Language"
        case contentMD5 = "Content-MD5"
        case cacheControl = "Cache-Control"
        case contentDisposition = "Content-Disposition"
        case blobType = "BlobType"
        case accessTier = "AccessTier"
        case accessTierInferred = "AccessTierInferred"
        case leaseStatus = "LeaseStatus"
        case leaseState = "LeaseState"
        case serverEncrypted = "ServerEncrypted"
    }
}

// Define the Blob model to hold each Blob's name and properties
struct Blob: Codable {
    let name: String?
    let properties: BlobProperties?
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case properties = "Properties"
    }
}

struct BlobName: Codable {
    let blob: [Blob]
    private enum CodingKeys: String, CodingKey {
        case blob = "Blob"
    }
}

// Define the top-level model for the entire XML structure
struct EnumerationBlobResults: Codable {
    let serviceEndpoint: String
    let containerName: String
    let blobs: BlobName

    // Key mapping for XML attributes to Swift properties
    private enum CodingKeys: String, CodingKey {
        case serviceEndpoint = "ServiceEndpoint"
        case containerName = "ContainerName"
        case blobs = "Blobs"
    }
}
