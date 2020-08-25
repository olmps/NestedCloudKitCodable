//
//  CKEncoderSingleValueContainer.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CloudKit
import Foundation

internal class CKEncoderSingleValueContainer: SingleValueEncodingContainer {

    private let object: CKEncodable
    private let zoneID: CKRecordZone.ID?
    private var createdRecords: BoxedArray<CKRecord>
    var codingPath: [CodingKey]

    init(object: CKEncodable, zoneID: CKRecordZone.ID?, createdRecords: BoxedArray<CKRecord>, codingPath: [CodingKey]) {
        self.object = object
        self.zoneID = zoneID
        self.createdRecords = createdRecords
        self.codingPath = codingPath
    }
}

extension CKEncoderSingleValueContainer {

    func encodeNil() throws { }

    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = CloudKitRecordEncoder(object: object, zoneID: zoneID, createdRecords: createdRecords)
        try value.encode(to: encoder)
    }
}
