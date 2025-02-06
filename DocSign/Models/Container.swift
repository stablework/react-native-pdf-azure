//
//  Container.swift
//  DocSign
//
//  Created by admin on 1/29/25.
//
import Foundation

// Struct to represent each container
//struct Container {
//    let name: String
//    let etag: String
//    let leaseStatus: String
//}


import Foundation

// Define the Properties of each Container
struct ContainerProperties: Codable {
    let lastModified: String
    let etag: String
    let leaseStatus: String
    let leaseState: String
    let hasImmutabilityPolicy: Bool
    let hasLegalHold: Bool
    let publicAccess: String?

    // Coding Keys to match XML elements
    private enum CodingKeys: String, CodingKey {
        case lastModified = "Last-Modified"
        case etag = "Etag"
        case leaseStatus = "LeaseStatus"
        case leaseState = "LeaseState"
        case hasImmutabilityPolicy = "HasImmutabilityPolicy"
        case hasLegalHold = "HasLegalHold"
        case publicAccess = "PublicAccess"
    }
}

// Define the Container model that contains the Name and Properties
struct Container: Codable {
    let name: String
    let properties: ContainerProperties
    
    // Coding Keys to map XML element names to Swift property names
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case properties = "Properties"
    }
}

// Define the Container model that contains the Name and Properties
struct ContainerName: Codable {
    let containerName: [Container]
    
    // Coding Keys to map XML element names to Swift property names
    private enum CodingKeys: String, CodingKey {
        case containerName = "Container"
    }
}

// Define the root model EnumerationResults which contains the ServiceEndpoint and Containers
struct EnumerationContainerResults: Codable {
    let serviceEndpoint: String
    let containers: ContainerName

    // Coding Keys to match XML structure
    private enum CodingKeys: String, CodingKey {
        case serviceEndpoint = "ServiceEndpoint"
        case containers = "Containers"
    }
}
