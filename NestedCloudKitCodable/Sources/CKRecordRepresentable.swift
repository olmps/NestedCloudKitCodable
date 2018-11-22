//
//  CKRecordRepresentable.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation
import CloudKit

public protocol CKRecordRepresentable {
    var cloudKitRecordType: String { get }
    var cloudKitIdentifier: String { get }
    
    func ignoredProperties() -> [String]
}

public extension CKRecordRepresentable {
    func ignoredProperties() -> [String] { return [] }
}

public protocol CKEncodable: CKRecordRepresentable & Encodable {
    
}

public protocol CKDecodable: CKRecordRepresentable & Decodable {
    
}

public protocol CKCodable: CKEncodable & CKDecodable { }
