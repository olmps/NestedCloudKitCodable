//
//  CKRecordDecoder.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation
import CloudKit

public class CKRecordDecoder {
    
    public init() { }
    
    /**
        Decode a custom object given it's record and a reference database.
        - important: this functions is asynchronous and can take several seconds -
        depending of how deeply nested is your object (to other references) and the internet speed.
     
        - parameter type: The object type to decode
        - parameter record: The most top level object record fetched from Cloudkit
        - parameter referenceDatabase: The database used for fetch nested values
        - parameter completion: Closure with the decoded object or an error. The error is from type `CloudkitCodableError` and
        it has a description associated explaining what may have happened
     */
    func decode<T>(_ type: T.Type,
                   from record: CKRecord,
                   referenceDatabase database: CKDatabase,
                   completion: @escaping (_ result: T?, _ error: CKCodableError?) -> Void) where T: Decodable {
        
        fetchAllAssociatedRecords(fromReferences: record.references,
                                  recordsStack: [record],
                                  referenceDatabase: database) { (records, error) in
            if let error = error {
                completion(nil, error)
            } else if let records = records {
                let decoder = _CKRecordDecoder(records: records)
                do {
                    let decodedValue = try T(from: decoder)
                    completion(decodedValue, nil)
                } catch let error as CKCodableError {
                    completion(nil, error)
                } catch { }
            }
        }
    }
    
    /**
        Fetch all records associated with the base record.
     
        It queries the `referenceDatabase` looking for references and other associated records.
        It's important that before the decoding starts, it's necessary to have all the associated
        records with the base object.
     */
    private func fetchAllAssociatedRecords(fromReferences references: [CKRecord.Reference],
                                           recordsStack records: [CKRecord],
                                           referenceDatabase database: CKDatabase,
                                           completion: @escaping ([CKRecord]?, CKCodableError?) -> Void) {
        let query = CKFetchRecordsOperation(recordIDs: references.map { $0.recordID })
        query.fetchRecordsCompletionBlock = { [unowned self] (recordsDictionary, error) in
            if let receivedError = error {
                let error = CKCodableError.error(fromCloudkitError: receivedError)
                completion(nil, error)
                return
            }
            
            if let fetchedRecordsDictionary = recordsDictionary {
                
                let fetchedRecords = fetchedRecordsDictionary.map { $0.value }
                self.fetchReferences(fromRecords: fetchedRecords,
                                     andAppendTo: records,
                                     withReferenceDatabase: database,
                                     completion: completion)
                
            } else {
                let error = CKCodableError(.cloudkitInconsistence)
                completion(nil, error)
            }
        }
        database.add(query)
    }
    
    /**
        Fetch all references associated with records from a CKRecord array.
     
        This is an auxiliar function that iterates through an array of CKRecord and fetch
        all CKReferences related to each one of the CKRecords.
     */
    private func fetchReferences(fromRecords records: [CKRecord],
                                 andAppendTo recordsStack: [CKRecord],
                                 withReferenceDatabase database: CKDatabase,
                                 completion: @escaping ([CKRecord]?, CKCodableError?) -> Void) {
        
        var actualRecordsStack = recordsStack
        actualRecordsStack.append(contentsOf: records)
        
        var existantReferences = [CKRecord.Reference]()
        records.forEach {
            $0.references.forEach {
                existantReferences.append($0)
            }
        }
        
        if existantReferences.isEmpty {
            completion(recordsStack, nil)
        } else {
            fetchAllAssociatedRecords(fromReferences: existantReferences,
                                      recordsStack: recordsStack,
                                      referenceDatabase: database,
                                      completion: completion)
        }
    }
}

internal class _CKRecordDecoder: Decoder {
    
    private let allRecords: [CKRecord]
    private let recordBeingAnalyzed: CKRecord
    public var codingPath: [CodingKey] = []
    public var userInfo: [CodingUserInfoKey : Any] {
        return [:]
    }
    
    // UnkeyedContainer control vars
    var unkeyedElements: [Decodable] = []
    var unkeyedRecords: [CKRecord] = []
    var state: CKDecoderUnkeyedContainer.State = .records
    
    init(records: [CKRecord], recordBeingAnalyzed: CKRecord? = nil) {
        self.allRecords = records
        self.recordBeingAnalyzed = recordBeingAnalyzed ?? records.first!
    }
    
    /**
        Responsible for decoding keyed elements, i.e, CKRecords which are handled as dictionaries.
     */
    public func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let keyedContainer = CKDecoderKeyedContainer<Key>(records: allRecords, recordBeingAnalyzed: recordBeingAnalyzed, codingPath: codingPath)
        return KeyedDecodingContainer(keyedContainer)
    }
    
    /**
        Responsible for decoding unkeyed elements, i.e, all types of collections such as array of CKRecord.Reference.
     */
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let unkeyedContainer = CKDecoderUnkeyedContainer(records: allRecords, elements: unkeyedElements, receivedRecords: unkeyedRecords, state: state, codingPath: codingPath)
        return unkeyedContainer
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        let singleValueDecoder = CKDecoderSingleValueContainer(records: allRecords,
                                                               recordBeingAnalyzed: recordBeingAnalyzed,
                                                               codingPath: codingPath)
        return singleValueDecoder
    }
}
