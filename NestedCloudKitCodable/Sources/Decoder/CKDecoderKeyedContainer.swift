//
//  CKDecoderKeyedContainer.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CloudKit
import Foundation

internal class CKDecoderKeyedContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
    
    private let records: [CKRecord]
    private let recordBeingAnalyzed: CKRecord!
    private var record: CKRecord {
        return recordBeingAnalyzed
    }
    
    var codingPath: [CodingKey]
    
    init(records: [CKRecord], recordBeingAnalyzed: CKRecord, codingPath: [CodingKey]) {
        self.records = records
        self.recordBeingAnalyzed = recordBeingAnalyzed
        self.codingPath = codingPath
    }
    
    func checkCanDecodeValue(forKey key: Key) throws {
        guard self.contains(key) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "key not found: \(key)")
            throw DecodingError.keyNotFound(key, context)
        }
    }
}

extension CKDecoderKeyedContainer {
    
    var allKeys: [Key] {
        return self.record.allKeys().compactMap { Key(stringValue: $0) }
    }
    
    func contains(_ key: Key) -> Bool {
        return allKeys.contains(where: { $0.stringValue == key.stringValue })
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try checkCanDecodeValue(forKey: key)
        return record[key.stringValue] == nil
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        try checkCanDecodeValue(forKey: key)
        
        // Decode an unique CKRecord.Reference
        if let reference = record[key.stringValue] as? CKRecord.Reference {
            return try decodeSingleReference(reference, type: type)
        }
        
        // Decode an array of CKRecord.Reference
        if let references = record[key.stringValue] as? [CKRecord.Reference] {
            return try decodeReferenceSequence(references, type: type)
        }
        
        // Decode an array of primite elements, such as String for example.
        if let primitiveValues = record[key.stringValue] as? [T] {
            return try decodePrimitiveElementSequence(primitiveValues, type: type)
        }
        
        // Decode an unique primitive value
        if let value = record[key.stringValue] {
            return try decodeCKRecordValue(value, forKey: key)
        }
        
        throw CKCodableError(.typeMismatch, context: ["Error:": "Couldn't convert value \(String(describing: type)) to CKRecodValue"])
    }
    
    // MARK: Decode Helper Functions
    
    private func decodeCKRecordValue<T>(_ value: CKRecordValue, forKey key: Key) throws -> T where T: Decodable {
        
        if let asset = value as? CKAsset {
            let data = try Data(contentsOf: asset.fileURL)
            return data as! T
        }
        
        if let assets = value as? [CKAsset] {
            var datas = [Data]()
            try assets.forEach {
                let data = try Data(contentsOf: $0.fileURL)
                datas.append(data)
            }
            return datas as! T
        }
        
        if let locationValue = value as? CLLocation {
            return "\(locationValue.coordinate.latitude);\(locationValue.coordinate.longitude)" as! T
        }
        
        if let locationsValues = value as? [CLLocation] {
            var locations = [String]()
            locationsValues.forEach {
                let value = "\($0.coordinate.latitude);\($0.coordinate.longitude)"
                locations.append(value)
            }
            return locations as! T
        }
        
        return value as! T
        
    }
    
    private func decodeSingleReference<T>(_ reference: CKRecord.Reference, type: T.Type) throws -> T where T: Decodable {
        guard let associatedRecord = records.first(where: { record -> Bool in
            record.recordID == reference.recordID
        }) else {
            throw CKCodableError(.recordNotFound)
        }
        
        let decoder = _CKRecordDecoder(records: records, recordBeingAnalyzed: associatedRecord)
        return try T(from: decoder)
    }
    
    private func decodeReferenceSequence<T>(_ references: [CKRecord.Reference], type: T.Type) throws -> T where T: Decodable {
        var referencesRecords = [CKRecord]()
        for reference in references {
            // For each reference, find its origin CKRecord. All nested objects CKRecords where fetched before decoding.
            let associatedRecord = records.first(where: { record -> Bool in
                record.recordID == reference.recordID
            })
            guard let unwrappedRecord = associatedRecord else {
                throw CKCodableError(.recordNotFound)
            }
            referencesRecords.append(unwrappedRecord)
        }
        let decoder = _CKRecordDecoder(records: records, recordBeingAnalyzed: record)
        decoder.state = .records
        decoder.unkeyedRecords = referencesRecords
        return try T(from: decoder)
    }
    
    private func decodePrimitiveElementSequence<T>(_ elements: [T], type: T.Type) throws -> T where T: Decodable {
        let decoder = _CKRecordDecoder(records: records, recordBeingAnalyzed: record)
        decoder.state = .elements
        decoder.unkeyedElements = elements
        return try T(from: decoder)
    }
    
    // MARK: Other Decoder Functions
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        guard let elements = record[key.stringValue] as? [Decodable] else {
            fatalError("todo error layer")
        }
        let nestedUnkeyedContainer = CKDecoderUnkeyedContainer(records: records,
                                                               elements: elements,
                                                               receivedRecords: [],
                                                               state: .elements,
                                                               codingPath: codingPath)
        return nestedUnkeyedContainer
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let nestedKeyedContainer = CKDecoderKeyedContainer<NestedKey>(records: records,
                                                                      recordBeingAnalyzed: recordBeingAnalyzed,
                                                                      codingPath: codingPath)
        return KeyedDecodingContainer(nestedKeyedContainer)
    }
    
    func superDecoder() throws -> Decoder {
        return _CKRecordDecoder(records: records)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _CKRecordDecoder(records: records)
        decoder.codingPath = [key]
        
        return decoder
    }
}
