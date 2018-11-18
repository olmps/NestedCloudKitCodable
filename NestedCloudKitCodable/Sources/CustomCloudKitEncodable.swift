//
//  CustomCloudKitEncodable.swift
//  CloudKitCodable
//
//  Created by Guilherme Rambo on 11/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import CloudKit

public protocol CloudKitRecordRepresentable {
    var cloudKitRecordType: String { get }
    var cloudKitIdentifier: String { get }
    
    func ignoredProperties() -> [String]
}

extension CloudKitRecordRepresentable {
    func ignoredProperties() -> [String] { return [] }
}

public protocol CustomCloudKitEncodable: CloudKitRecordRepresentable & Encodable {
    
}

public protocol CustomCloudKitDecodable: CloudKitRecordRepresentable & Decodable {
    
}

public protocol CustomCloudKitCodable: CustomCloudKitEncodable & CustomCloudKitDecodable { }
