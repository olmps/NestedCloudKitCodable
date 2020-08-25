//
//  CKRecordEncoder.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation
import CloudKit

public class CKRecordEncoder {

    public var zoneID: CKRecordZone.ID?

    public init(zoneID: CKRecordZone.ID? = nil) {
        self.zoneID = zoneID
    }

    /**
         Encode a custom object into an array of CKRecord.
         - important: The encode function performs a nested encode, that's why the function returns an array of
            CKRecord values. Each CKRecord represents a nested object. You can just save this records to your
            Cloudkit database, since all references are set as well.
 
     - parameter value: The object to encode.
         - returns: The array of CKRecord, including the sent one.
     */
    public func encode(_ value: CKEncodable) throws -> [CKRecord] {
        let createdRecords = BoxedArray<CKRecord>()

        let encoder = CloudKitRecordEncoder(object: value, zoneID: zoneID, createdRecords: createdRecords)

        try value.encode(to: encoder)

        if let lastRecord = encoder.generatedRecord {
            createdRecords.append(lastRecord)
        }

        return createdRecords.array.filteredByUniqueIds()
    }
}

internal class CloudKitRecordEncoder: Encoder {

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    private var createdRecords: BoxedArray<CKRecord>
    private let zoneID: CKRecordZone.ID?
    private let object: CKEncodable

    private var keyedContainer: CKKeyedEncoder?

    var generatedRecord: CKRecord? { keyedContainer?.generatedRecord }

    init(object: CKEncodable, zoneID: CKRecordZone.ID?, createdRecords: BoxedArray<CKRecord>) {
        self.object = object
        self.zoneID = zoneID
        self.createdRecords = createdRecords
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = CKEncoderKeyedContainer<Key>(object: object, zoneID: zoneID,
                                                     codingPath: codingPath, createdRecords: createdRecords)
        keyedContainer = container
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        CKEncoderUnkeyedContainer(object: object, zoneID: zoneID,
                                  createdRecords: createdRecords, codingPath: codingPath)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        CKEncoderSingleValueContainer(object: object, zoneID: zoneID,
                                      createdRecords: createdRecords, codingPath: codingPath)
    }
}
