//
//  CloudKitRecordEncoder.swift
//  CloudKitCodable
//
//  Created by Guilherme Rambo on 11/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import CloudKit

public class CloudKitRecordEncoder {
    
    public var zoneID: CKRecordZone.ID?
    
    public init(zoneID: CKRecordZone.ID? = nil) {
        self.zoneID = zoneID
    }
    
    /**
     Encode a custom object into an array of CKRecord.
     - important: The encode function performs a nested encode, that's why the function returns an array of
        CKRecord values. Each CKRecord represents a nested object. You can just save this recrods to your
        Cloudkit database, since all references are set as well.
     
     - parameter value: The object to encode.
     - returns: The array of CKRecord, including the sent one.
     */
    public func encode(_ value: CustomCloudKitEncodable) throws -> [CKRecord] {
        let createdRecords = BoxedArray<CKRecord>()
        
        let encoder = _CloudKitRecordEncoder(object: value,
                                             zoneID: zoneID,
                                             createdRecords: createdRecords)
        try value.encode(to: encoder)
        
        if let lastRecord = encoder.generatedRecord {
            createdRecords.array.append(lastRecord)
        }
        
        return createdRecords.array.filteredByUniqueIds()
    }
}

internal class _CloudKitRecordEncoder: Encoder {
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    private var createdRecords: BoxedArray<CKRecord>
    private let zoneID: CKRecordZone.ID?
    private let object: CustomCloudKitEncodable
    
    private var keyedContainer: CustomCloudkitKeyedEncoder?
    
    var generatedRecord: CKRecord? {
        return keyedContainer?.generatedRecord
    }
    
    init(object: CustomCloudKitEncodable, zoneID: CKRecordZone.ID?, createdRecords: BoxedArray<CKRecord>) {
        self.object = object
        self.zoneID = zoneID
        self.createdRecords = createdRecords
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = CKEncoderKeyedContainer<Key>(object: object,
                                                     zoneID: zoneID,
                                                     codingPath: codingPath,
                                                     createdRecords: createdRecords)
        keyedContainer = container
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let unkeyedContainer = CKEncoderUnkeyedContainer(object: object,
                                                         zoneID: zoneID,
                                                         createdRecords: createdRecords,
                                                         codingPath: codingPath)
        return unkeyedContainer
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let singleValueEncoder = CKEncoderSingleValueContainer(object: object,
                                                               zoneID: zoneID,
                                                               createdRecords: createdRecords,
                                                               codingPath: codingPath)
        
        return singleValueEncoder
    }
}
