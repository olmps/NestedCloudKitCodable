//
//  CKEncoderUnkeyedContainer.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CloudKit
import Foundation

internal class CKEncoderUnkeyedContainer: UnkeyedEncodingContainer {

    private let object: CKEncodable
    private let zoneID: CKRecordZone.ID?
    private var createdRecords: BoxedArray<CKRecord>
    var codingPath: [CodingKey]

    private let elements: [Decodable]
    private var current: Int

    private var element: Decodable { elements[current] }

    init(object: CKEncodable, zoneID: CKRecordZone.ID?, createdRecords: BoxedArray<CKRecord>,
         elements: [Decodable] = [], current: Int = 0, codingPath: [CodingKey]) {
        self.object = object
        self.zoneID = zoneID
        self.createdRecords = createdRecords
        self.codingPath = codingPath
        self.elements = elements
        self.current = current
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
        -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let keyedContainer = CKEncoderKeyedContainer<NestedKey>(object: object, zoneID: zoneID,
                                                                codingPath: codingPath, createdRecords: createdRecords)
        return KeyedEncodingContainer(keyedContainer)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        CKEncoderUnkeyedContainer(object: object, zoneID: zoneID,
                                  createdRecords: createdRecords, codingPath: codingPath)
    }

    func superEncoder() -> Encoder {
        CloudKitRecordEncoder(object: object, zoneID: zoneID, createdRecords: createdRecords)
    }
}

extension CKEncoderUnkeyedContainer {

    var currentIndex: Int { current }
    var count: Int { elements.count }
    var isAtEnd: Bool { currentIndex > (count - 1) }

    func encodeNil() throws { }

    func encode<T>(_ value: T) throws where T: Encodable {
        guard let encoderValue = value as? CKEncodable else { return }

        let encoder = CloudKitRecordEncoder(object: encoderValue, zoneID: zoneID, createdRecords: createdRecords)

        try value.encode(to: encoder)

        if let generatedRecord = encoder.generatedRecord {
            createdRecords.append(generatedRecord)
        }

        current += 1
    }
}
