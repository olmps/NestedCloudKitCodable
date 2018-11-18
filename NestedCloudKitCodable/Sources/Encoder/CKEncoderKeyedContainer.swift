//
//  CKEncoderKeyedContainer.swift
//  Hercules-iOS
//
//  Created by Guilherme Girotto on 14/11/18.
//  Copyright © 2018 Hercules. All rights reserved.
//

import CloudKit
import Foundation

internal class CKEncoderKeyedContainer<Key>: CustomCloudkitKeyedEncoder where Key: CodingKey {
    
    private let object: CustomCloudKitEncodable
    private let zoneID: CKRecordZone.ID?
    var codingPath: [CodingKey]
    private var createdRecords: BoxedArray<CKRecord>
    
    fileprivate var storage: [String: CKRecordValue] = [:]
    
    init(object: CustomCloudKitEncodable,
         zoneID: CKRecordZone.ID?,
         codingPath: [CodingKey],
         createdRecords: BoxedArray<CKRecord>) {
        self.object = object
        self.zoneID = zoneID
        self.codingPath = codingPath
        self.createdRecords = createdRecords
    }
}

extension CKEncoderKeyedContainer {
    
    var recordID: CKRecord.ID {
        let zid = zoneID ?? CKRecordZone.ID(zoneName: CKRecordZone.ID.defaultZoneName, ownerName: CKCurrentUserDefaultName)
        return CKRecord.ID(recordName: object.cloudKitIdentifier, zoneID: zid)
    }
    
    var generatedRecord: CKRecord {
        let output = CKRecord(recordType: object.cloudKitRecordType, recordID: recordID)
        
        for (key, value) in storage {
            output[key] = value
        }
        
        return output
    }
}

extension CKEncoderKeyedContainer: KeyedEncodingContainerProtocol {
    
    func encodeNil(forKey key: Key) throws {
        storage[key.stringValue] = nil
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        guard !object.ignoredProperties().contains(key.stringValue) else {
            return
        }
        /**
            Encode a single value
         */
        if let singleValue = value as? CustomCloudKitEncodable {
            try encodeSingleValue(singleValue, forKey: key)
            return
        }
        
        /**
            Encode a an array of values
         */
        if let values = value as? [CustomCloudKitEncodable] {
            try encodeValuesSequence(originValue: value, castedValues: values, forKey: key)
            return
        }
        
        /**
            Encode an unique primitve type
         */
        if let ckValue = value as? CKRecordValue {
            try encodeCKRecordValue(ckValue, forKey: key)
            return
        }
    }
    
    // MARK: Auxiliar Encode functions
    
    private func encodeSingleValue(_ value: CustomCloudKitEncodable, forKey key: Key) throws {
        storage[key.stringValue] = try produceReference(for: value)
        let encoder = _CloudKitRecordEncoder(object: value,
                                             zoneID: zoneID,
                                             createdRecords: createdRecords)
        try value.encode(to: encoder)
        if let generatedRecord = encoder.generatedRecord {
            createdRecords.append(generatedRecord)
        }
    }
    
    private func encodeValuesSequence<T>(originValue value: T, castedValues: [CustomCloudKitEncodable], forKey key: Key) throws where T: Encodable {
        var references = [CKRecord.Reference]()
        try castedValues.forEach {
            let reference = try produceReference(for: $0)
            references.append(reference)
        }
        storage[key.stringValue] = references as CKRecordValue
        let encoder = _CloudKitRecordEncoder(object: object,
                                             zoneID: zoneID,
                                             createdRecords: createdRecords)
        try value.encode(to: encoder)
    }
    
    private func encodeCKRecordValue(_ value: CKRecordValue, forKey key: Key) throws {
        
        if let data = value as? Data {
            let tempStr = ProcessInfo.processInfo.globallyUniqueString
            let filename = "\(tempStr)_file.bin"
            let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL = baseURL.appendingPathComponent(filename, isDirectory: false)
            try data.write(to: fileURL, options: .atomic)
            let asset = CKAsset(fileURL: fileURL)
            storage[key.stringValue] = asset
            return
        }
        
        if let datas = value as? [Data] {
            var assets = [CKAsset]()
            for i in 0..<datas.count {
                let data = datas[i]
                let tempStr = ProcessInfo.processInfo.globallyUniqueString
                let filename = "\(tempStr)_file.bin"
                let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
                let fileURL = baseURL.appendingPathComponent(filename, isDirectory: false)
                try data.write(to: fileURL, options: .atomic)
                let asset = CKAsset(fileURL: fileURL)
                assets.append(asset)
            }
            storage[key.stringValue] = assets as CKRecordValue
        }
        
        if let url = value as? URL {
            let asset = CKAsset(fileURL: url)
            storage[key.stringValue] = asset
            return
        }
        
        if let urls = value as? [URL] {
            var assets = [CKAsset]()
            for i in 0..<urls.count {
                let url = urls[i]
                let asset = CKAsset(fileURL: url)
                assets.append(asset)
            }
            storage[key.stringValue] = assets as CKRecordValue
            return
        }
        
        /**
            CLLocations are encoded as Strings, since Swift Codable protocol
            cant encode/decode this type of values. The format chosen to encode
            this values is "lat;long".
         */
        if let locationString = value as? String,
            locationString.contains(";") {
            
            let split = locationString.split(separator: ";")
            
            guard let latitude = Double(split[0]),
                let longitude = Double(split[1]) else {
                    storage[key.stringValue] = nil
                    return
            }
            
            storage[key.stringValue] = CLLocation(latitude: latitude, longitude: longitude)
            return
        }
        
        if let locationsStrings = value as? [String],
            let firstString = locationsStrings.first,
            firstString.contains(";") {
            
            var locations = [CLLocation]()
            locationsStrings.forEach {
                let split = $0.split(separator: ";")
                guard let latitude = Double(split[0]),
                    let longitude = Double(split[1]) else {
                        storage[key.stringValue] = nil
                        return
                }
                let location = CLLocation(latitude: latitude, longitude: longitude)
                locations.append(location)
            }
            
            storage[key.stringValue] = locations as CKRecordValue
        }
        
        storage[key.stringValue] = value
    }
    
    private func produceReference(for value: CustomCloudKitEncodable) throws -> CKRecord.Reference {
        let recordID = CKRecord.ID(recordName: value.cloudKitIdentifier)
        return CKRecord.Reference(recordID: recordID, action: .deleteSelf)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let unkeyedContainer = CKEncoderUnkeyedContainer(object: object,
                                                         zoneID: zoneID,
                                                         createdRecords: createdRecords,
                                                         codingPath: codingPath)
        return unkeyedContainer
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let nestedKeyedContainer = CKEncoderKeyedContainer<NestedKey>(object: object,
                                                                      zoneID: zoneID,
                                                                      codingPath: codingPath,
                                                                      createdRecords: createdRecords)
        return KeyedEncodingContainer(nestedKeyedContainer)
    }
    
    func superEncoder() -> Encoder {
        return _CloudKitRecordEncoder(object: object,
                                      zoneID: zoneID,
                                      createdRecords: createdRecords)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return _CloudKitRecordEncoder(object: object,
                                      zoneID: zoneID,
                                      createdRecords: createdRecords)
    }
}
