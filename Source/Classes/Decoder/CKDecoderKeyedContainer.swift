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
    private var record: CKRecord { recordBeingAnalyzed }

    var codingPath: [CodingKey]

    init(records: [CKRecord], recordBeingAnalyzed: CKRecord, codingPath: [CodingKey]) {
        self.records = records
        self.recordBeingAnalyzed = recordBeingAnalyzed
        self.codingPath = codingPath
    }

    func checkCanDecodeValue(forKey key: Key) throws {
        guard contains(key) else {
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "Key not found: \(key)")
            throw DecodingError.keyNotFound(key, context)
        }
    }
}

extension CKDecoderKeyedContainer {

    var allKeys: [Key] { record.allKeys().compactMap { Key(stringValue: $0) } }

    func contains(_ key: Key) -> Bool { allKeys.contains(where: { $0.stringValue == key.stringValue }) }

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

        throw CKCodableError(.typeMismatch,
                             context: ["Error:": "Couldn't convert value \(String(describing: type)) to CKRecodValue"])
    }

    // MARK: Decode Helper Functions
    // swiftlint:disable:next cyclomatic_complexity
    private func decodeCKRecordValue<T>(_ value: CKRecordValue, forKey key: Key) throws -> T where T: Decodable {
        if let asset = value as? CKAsset {
            guard let assetURL = asset.fileURL, let data = try Data(contentsOf: assetURL) as? T else {
                let context = ["Error:": "Couldn't convert Data value to \(String(describing: T.self))"]
                throw CKCodableError(.typeMismatch, context: context)
            }
            return data
        }

        if let assets = value as? [CKAsset] {
            var datas = [Data]()
            for asset in assets {
                guard let assetURL = asset.fileURL else { continue }
                let data = try Data(contentsOf: assetURL)
                datas.append(data)
            }
            guard let castedDatas = datas as? T else {
                let context = ["Error:": "Couldn't convert [Data] value to \(String(describing: T.self))"]
                throw CKCodableError(.typeMismatch, context: context)
            }
            return castedDatas
        }

        if let locationValue = value as? CLLocation {
            let latitude = locationValue.coordinate.latitude
            let longitude = locationValue.coordinate.longitude
            let separator = Constants.locationSeparator
            let locationStringValue = "\(latitude)\(separator)\(longitude)"

            guard let locationValue = locationStringValue as? T else {
                let context = ["Error:": "Couldn't convert String value to \(String(describing: T.self))"]
                throw CKCodableError(.typeMismatch, context: context)
            }
            return locationValue
        }

        if let locationsValues = value as? [CLLocation] {
            var locations = [String]()
            locationsValues.forEach {
                let value = "\($0.coordinate.latitude)\(Constants.locationSeparator)\($0.coordinate.longitude)"
                locations.append(value)
            }
            guard let castedLocations = locations as? T else {
                let context = ["Error:": "Couldn't convert [String] value to \(String(describing: T.self))"]
                throw CKCodableError(.typeMismatch, context: context)
            }
            return castedLocations
        }

        guard let decodableValue = value as? T else {
            let context = ["Error:": "Couldn't convert \(value) value to \(String(describing: T.self))"]
            throw CKCodableError(.typeMismatch, context: context)
        }

        return decodableValue
    }

    private func decodeSingleReference<T>(_ reference: CKRecord.Reference,
                                          type: T.Type) throws -> T where T: Decodable {
        guard let associatedRecord = records.first(where: { record -> Bool in
            record.recordID == reference.recordID
        }) else {
            throw CKCodableError(.recordNotFound)
        }

        let decoder = InternalCKRecordDecoder(records: records, recordBeingAnalyzed: associatedRecord)
        return try T(from: decoder)
    }

    private func decodeReferenceSequence<T>(_ references: [CKRecord.Reference],
                                            type: T.Type) throws -> T where T: Decodable {
        var referencesRecords = [CKRecord]()
        for reference in references {
            // For each reference, find its origin CKRecord. All nested objects CKRecords were fetched before decoding.
            let associatedRecord = records.first(where: { record -> Bool in
                record.recordID == reference.recordID
            })
            guard let unwrappedRecord = associatedRecord else {
                throw CKCodableError(.recordNotFound)
            }
            referencesRecords.append(unwrappedRecord)
        }
        let decoder = InternalCKRecordDecoder(records: records, recordBeingAnalyzed: record)
        decoder.state = .records
        decoder.unkeyedRecords = referencesRecords
        return try T(from: decoder)
    }

    private func decodePrimitiveElementSequence<T>(_ elements: [T], type: T.Type) throws -> T where T: Decodable {
        let decoder = InternalCKRecordDecoder(records: records, recordBeingAnalyzed: record)
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

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type,
                                    forKey key: Key) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let nestedKeyedContainer = CKDecoderKeyedContainer<NestedKey>(records: records,
                                                                      recordBeingAnalyzed: recordBeingAnalyzed,
                                                                      codingPath: codingPath)
        return KeyedDecodingContainer(nestedKeyedContainer)
    }

    func superDecoder() throws -> Decoder {
        return InternalCKRecordDecoder(records: records)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = InternalCKRecordDecoder(records: records)
        decoder.codingPath = [key]

        return decoder
    }
}
